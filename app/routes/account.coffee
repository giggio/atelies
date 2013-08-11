Product         = require '../models/product'
User            = require '../models/user'
Store           = require '../models/store'
Order           = require '../models/order'
_               = require 'underscore'
everyauth       = require 'everyauth'
AccessDenied    = require '../errors/accessDenied'
values          = require '../helpers/values'
correios        = require 'correios'
RouteFunctions  = require './routeFunctions'

class Routes
  constructor: (@env) ->
    @_auth 'changePasswordShow', 'changePassword', 'updateProfile', 'updateProfileShow', 'profileUpdated', 'account'

  account: (req, res) ->
    user = req.user
    Order.getSimpleByUser user, (err, orders) ->
      return res.send 400 if err?
      user.toSimpleUser (user) ->
        res.render 'account', user: user, orders: orders

  resendConfirmationEmail: (req, res) ->
    user = req.user
    user.sendMailConfirmRegistration (err, mailResponse) ->
      res.json 400, err if err?
      res.send 200

  updateProfileShow: (req, res) ->
    user = req.user
    redirectTo = if req.query.redirectTo? then "?redirectTo=#{encodeURIComponent req.query.redirectTo}" else ""
    res.render 'updateProfile', user:
      name: user.name
      deliveryStreet: user.deliveryAddress.street
      deliveryStreet2: user.deliveryAddress.street2
      deliveryCity: user.deliveryAddress.city
      deliveryState: user.deliveryAddress.state
      deliveryZIP: user.deliveryAddress.zip
      phoneNumber: user.phoneNumber
      isSeller: user.isSeller
    , states: values.states, redirectTo: redirectTo, facebookRegistration: req.query.facebookRegistration?

  updateProfile: (req, res) ->
    user = req.user
    body = req.body
    user.name = body.name
    user.deliveryAddress.street = body.deliveryStreet
    user.deliveryAddress.street2 = body.deliveryStreet2
    user.deliveryAddress.city = body.deliveryCity
    user.deliveryAddress.state = body.deliveryState
    user.deliveryAddress.zip = body.deliveryZIP
    user.phoneNumber = body.phoneNumber
    user.isSeller = true if body.isSeller
    user.save (error, user) =>
      if error?
        res.render 'updateProfile', errors: error.errors, user: body, states: values.states
      else
        redirectTo = if req.query.redirectTo? then "?redirectTo=#{encodeURIComponent req.query.redirectTo}" else ""
        res.redirect "account/profileUpdated#{redirectTo}"

  profileUpdated: (req, res) ->
    res.render 'profileUpdated', redirectTo: req.query.redirectTo
  
  changePasswordShow: (req, res) ->
    res.render 'changePassword'
  
  changePassword: (req, res) ->
    user = req.user
    email = user.email.toLowerCase()
    user.verifyPassword req.body.password, (error, succeeded) ->
      if error?
        return res.render 'changePassword', errors: [ 'Não foi possível trocar a senha. Erro ao verificar a senha.' ]
      if succeeded
        return res.render 'changePassword', errors: [ 'Senha não é forte.' ] unless /^(?=(?:.*[A-z]){1})(?=(?:.*\d){1}).{8,}$/.test req.body.newPassword
        user.setPassword req.body.newPassword
        user.save (err, user) ->
          if err?
            return res.render 'changePassword', errors: [ 'Não foi possível trocar a senha. Erro ao salvar o usuário.' ]
          res.redirect 'account/passwordChanged'
      else
        res.render 'changePassword', errors: [ 'Senha inválida.' ]
  
  passwordChanged: (req, res) ->
    res.render 'passwordChanged'
  
  notSeller: (req, res) -> res.render 'notseller'

  
  order: (req, res) ->
    user = req.user
    Order.getSimpleWithItemsByUserAndId user, req.params._id, (err, orders) ->
      return res.json 400, err if err?
      res.json orders

  verifyUser: (req, res) ->
    User.findById req.params._id, (err, user) ->
      return res.send 400 if err?
      user.verified = true
      user.save (err, user) ->
        return res.send 400 if err?
        res.redirect 'account/verified'

  verified: (req, res) -> res.render 'accountVerified'

  mustVerifyUser: (req, res) -> res.render 'accountMustVerifyUser'

  registered: (req, res) -> res.render 'accountRegistered'

  forgotPasswordShow: (req, res) -> res.render 'forgotPassword'

  forgotPassword: (req, res) ->
    return res.render 'forgotPassword' unless req.body.email?
    User.findByEmail req.body.email, (err, user) ->
      return res.render 'forgotPassword', error: 'Usuário não encontrado.' if err? or !user?
      user.sendMailPasswordReset (err, mailResponse) ->
        return res.render 'forgotPassword', error: 'Ocorreu um erro ao enviar o e-mail. Tente novamente mais tarde.' if err?
        user.save()
        res.redirect '/account/passwordResetSent'

  passwordResetSent: (req, res) -> res.render 'passwordResetSent'

  resetPasswordShow: (req, res) -> res.render 'resetPassword'

  resetPassword: (req, res) ->
    User.findById req.query._id, (err, user) ->
      return res.render 'resetPassword', error:err if err?
      return res.render 'resetPassword', error: 'Não foi possível trocar a senha.' unless user?.resetKey?
      if user.resetKey.toString() is req.query.resetKey
        return res.render 'resetPassword', error:'Senha não é forte.' unless /^(?=(?:.*[A-z]){1})(?=(?:.*\d){1}).{8,}$/.test req.body.newPassword
        user.setPassword req.body.newPassword
        user.save (err, user) ->
          return res.render 'resetPassword', error: 'Não foi possível trocar a senha. Erro ao salvar o usuário.' if err?
          res.redirect 'account/passwordChanged'
      else
        return res.render 'resetPassword', error: 'Não foi possível trocar a senha.'

_.extend Routes::, RouteFunctions::

module.exports = Routes
