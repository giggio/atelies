path          = require "path"
everyauth     = require 'everyauth'
User          = require '../models/user'
values        = require './values'
Recaptcha     = require('recaptcha').Recaptcha

exports.configure = (app) ->
  everyauth.password.configure
    logoutPath: '/account/logout'
    loginWith: "email"
    getLoginPath: "/account/login"
    postLoginPath: "/account/login"
    loginSuccessRedirect: "/"
    registerSuccessRedirect: "/"
    getRegisterPath: "/account/register"
    postRegisterPath: "/account/register"
    registerView: path.join app.get('views'), "register.jade"
    loginView: path.join app.get('views'), "login.jade"
    loginLocals: (req, res) ->
      if req.query.redirectTo?
        redirectTo: "?redirectTo=#{req.query.redirectTo}"
      else
        redirectTo: ''
    respondToLoginSucceed: (res, user, data) ->
      return unless user?
      if data.req.query.redirectTo?
        @redirect res, data.req.query.redirectTo
      else
        @redirect res, '/'
    #performRedirect: (res, location) -> res.redirect location, 302
    authenticate: (email, password) ->
      errors = []
      errors.push "Informe o e-mail" unless email?
      errors.push "Informe a senha" unless password?
      return errors if errors.length isnt 0
      cb = @Promise()
      User.findByEmail email.toLowerCase(), (error, user) ->
        return cb([error]) if error?
        return cb.fulfill ['Login falhou'] unless user?
        user.verifyPassword password, (error, succeeded) ->
          if error?
            cb.fail error
            return cb.fulfill ['Login falhou']
          cb.fulfill(if succeeded then user else ["Login falhou"])
      cb
    registerLocals: (req, res) ->
      recaptcha = new Recaptcha process.env.RECAPTCHA_PUBLIC_KEY, process.env.RECAPTCHA_PRIVATE_KEY
      states: values.states
      userParams: req.body
      recaptchaForm: recaptcha.toHTML()
    validateRegistration: (newUserAttrs, errors) ->
      email = newUserAttrs.email.toLowerCase()
      password = newUserAttrs.password
      cb = @Promise()
      unless /^(?=(?:.*[a-z]){1})(?=(?:.*[A-Z]){1})(?=(?:.*\d){1})(?=(?:.*[!@#$%^&*-]){1}).{10,}$/.test password
        errors.push "A senha não é forte."
        cb.fulfill errors
        return cb
      User.findByEmail email, (error, user) ->
        if error?
          errors.push error
          return cb.fulfill errors
        errors.push "E-mail já cadastrado." if user?
        if DEBUG
          cb.fulfill errors
        else
          data =
            remoteip:  newUserAttrs.remoteip
            challenge: newUserAttrs.captchaChallenge
            response:  newUserAttrs.captchaResponse
          recaptcha = new Recaptcha process.env.RECAPTCHA_PUBLIC_KEY, process.env.RECAPTCHA_PRIVATE_KEY, data
          recaptcha.verify (success, errorCode) ->
            errors.push "Código incorreto." unless success
            cb.fulfill errors
      cb
    registerUser: (newUserAttrs) ->
      cb = @Promise()
      password = newUserAttrs.password
      attrs =
        name: newUserAttrs.name
        email: newUserAttrs.email.toLowerCase()
        isSeller: newUserAttrs.isSeller
        deliveryAddress:
          street: newUserAttrs.deliveryStreet
          street2: newUserAttrs.deliveryStreet2
          city: newUserAttrs.deliveryCity
          state: newUserAttrs.deliveryState
          zip: newUserAttrs.deliveryZIP
        phoneNumber: newUserAttrs.phoneNumber
      user = new User attrs
      user.setPassword password
      user.save (error, user) -> cb.fulfill(if error? then [error] else user)
      cb

    extractExtraRegistrationParams: (req) ->
      remoteip: req.connection.remoteAddress
      captchaChallenge: req.body.recaptcha_challenge_field
      captchaResponse: req.body.recaptcha_response_field
      name: req.body.name
      email: req.body.email
      isSeller: req.body.isSeller?
      deliveryStreet: req.body.deliveryStreet
      deliveryStreet2: req.body.deliveryStreet2
      deliveryCity: req.body.deliveryCity
      deliveryState: req.body.deliveryState
      deliveryZIP: req.body.deliveryZIP
      phoneNumber: req.body.phoneNumber
  
  everyauth.everymodule.findUserById (req, userId, cb) ->
    User.findById userId, (error, user) ->
      #console.log "found user: #{user}"
      cb error, user
  everyauth.everymodule.userPkey '_id'
