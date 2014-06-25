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
Q               = require 'q'

module.exports = class AccountRoutes
  constructor: (@env) ->
    @_auth 'changePasswordShow', 'changePassword', 'updateProfile', 'updateProfileShow', 'profileUpdated', 'account', 'evaluationCreate'
  _.extend @::, RouteFunctions::

  handleError: @::_handleError.partial 'admin'

  logError: @::_logError.partial 'admin'

  account: (req, res) ->
    Q.all([
      Order.getSimpleByUser req.user
      req.user.toSimpleUser()
    ]).spread (orders, simpleUser) -> res.render 'account/account', user: simpleUser, orders: orders
    .catch (err) => @handleError req, res, err, false

  resendConfirmationEmail: (req, res) ->
    user = req.user
    user.sendMailConfirmRegistration null
    .then -> res.send 200
    .catch (err) => @handleError req, res, err

  updateProfileShow: (req, res) ->
    user = req.user
    redirectTo = if req.query.redirectTo? then "?redirectTo=#{encodeURIComponent req.query.redirectTo}" else ""
    res.render 'account/updateProfile', user:
      name: user.name
      deliveryStreet: user.deliveryAddress.street
      deliveryStreet2: user.deliveryAddress.street2
      deliveryCity: user.deliveryAddress.city
      deliveryState: user.deliveryAddress.state
      deliveryZIP: user.deliveryAddress.zip
      phoneNumber: user.phoneNumber
      isSeller: user.isSeller
    , states: values.states, redirectTo: redirectTo, facebookRegistration: req.query.facebookRegistration?

  afterFacebookLogin: (req, res) ->
    path = if req.session.existingUserLogin
      if req.query.redirectTo?
        req.query.redirectTo
      else
        '/#home'
    else
      '/account/updateProfile?facebookRegistration'
    res.redirect path

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
    Q.ninvoke user, 'save'
    .then (user) ->
      redirectTo = if req.query.redirectTo? then "?redirectTo=#{encodeURIComponent req.query.redirectTo}" else ""
      res.redirect "account/profileUpdated#{redirectTo}"
    .catch (err) -> res.render 'account/updateProfile', errors: error.errors, user: body, states: values.states

  profileUpdated: (req, res) -> res.render 'account/profileUpdated', redirectTo: req.query.redirectTo
  
  changePasswordShow: (req, res) -> res.render 'account/changePassword'
  
  changePassword: (req, res) ->
    user = req.user
    email = user.email.toLowerCase()
    user.verifyPassword req.body.password
    .catch (err) -> res.render 'account/changePassword', errors: [ 'Não foi possível trocar a senha. Erro ao verificar a senha.' ]
    .then (succeeded) ->
      if succeeded
        return res.render 'account/changePassword', errors: [ 'Senha não é forte.' ] unless /^(?=(?:.*[A-z]){1})(?=(?:.*\d){1}).{8,}$/.test req.body.newPassword
        user.setPassword req.body.newPassword
        Q.ninvoke user, 'save'
        .catch (err) -> res.render 'account/changePassword', errors: [ 'Não foi possível trocar a senha. Erro ao salvar o usuário.' ]
        .then -> res.redirect 'account/passwordChanged'
      else
        res.render 'account/changePassword', errors: [ 'Senha inválida.' ]
  
  passwordChanged: (req, res) -> res.render 'account/passwordChanged'
  
  notSeller: (req, res) -> res.render 'account/notseller'

  order: (req, res) ->
    Order.getSimpleWithItemsByUserAndId req.user, req.params._id
    .then (orders) -> res.json orders
    .catch (err) => @handleError req, res, err

  verifyUser: (req, res) ->
    Q.ninvoke User, 'findById', req.params._id
    .then (user) ->
      user.verified = true
      Q.ninvoke user, 'save'
    .then -> res.redirect 'account/verified' + if req.query?.redirectTo? then "?redirectTo=#{req.query.redirectTo}" else ""
    .catch (err) => @handleError req, res, err

  verified: (req, res) -> res.render 'account/accountVerified', redirectTo: if req.query?.redirectTo? then req.query.redirectTo else undefined

  mustVerifyUser: (req, res) -> res.render 'account/mustVerifyUser'

  registered: (req, res) -> res.render 'account/registered', redirectTo: req.query.redirectTo?

  forgotPasswordShow: (req, res) -> res.render 'account/forgotPassword'

  forgotPassword: (req, res) ->
    return res.render 'account/forgotPassword' unless req.body.email?
    User.findByEmail req.body.email
    .catch (err) => @handleError req, res, err, false
    .then (user) ->
      return res.render 'account/forgotPassword', error: 'Usuário não encontrado.' unless user?
      user.sendMailPasswordReset()
      .then ->
        user.save()
        res.redirect '/account/passwordResetSent'
      .catch (err) =>
        @logError req, err
        res.render 'account/forgotPassword', error: 'Ocorreu um erro ao enviar o e-mail. Tente novamente mais tarde.'

  passwordResetSent: (req, res) -> res.render 'account/passwordResetSent'

  resetPasswordShow: (req, res) -> res.render 'account/resetPassword'

  resetPassword: (req, res) ->
    Q.ninvoke User, 'findById', req.query._id
    .then (user) ->
      return res.render 'account/resetPassword', error: 'Não foi possível trocar a senha.' unless user?.resetKey?
      if user.resetKey.toString() is req.query.resetKey
        return res.render 'account/resetPassword', error:'Senha não é forte.' unless /^(?=(?:.*[A-z]){1})(?=(?:.*\d){1}).{8,}$/.test req.body.newPassword
        user.setPassword req.body.newPassword
        Q.ninvoke user, 'save'
        .then (user) -> res.redirect 'account/passwordChanged'
      else
        res.render 'account/resetPassword', error: 'Não foi possível trocar a senha.'
    .catch (err) => @handleError req, res, err, false

  evaluationCreate: (req, res) ->
    Q.ninvoke Order, "findById", req.params._id
    .then (order) -> order.addEvaluation user: req.user, body: req.body.body, rating: req.body.rating
    .then (result) ->
      Q.ninvoke result.evaluation, 'save'
      .then -> Q.ninvoke result.store, 'save'
      .then -> Q.ninvoke result.order, 'save'
      .then -> result.order.sendMailAfterEvaluation()
    .then -> res.send 201
    .catch (err) => @handleError req, res, err
