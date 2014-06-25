path          = require "path"
everyauth     = require 'everyauth'
User          = require '../models/user'
values        = require './values'
Recaptcha     = require('recaptcha').Recaptcha
config        = require './config'
Q             = require 'q'

exports.configure = (app) ->
  everyauth.facebook.configure
    appId: config.facebook.appId
    appSecret: config.facebook.appSecret
    scope: 'email'
    fields: 'id,name,email'
    handleAuthCallbackError: (req, res) ->
      res.render 'facebookAuthCallbackError'
    findOrCreateUser: (session, accessToken, accessTokExtra, fbUserMetadata) ->
      cb = @Promise()
      #fbUserMetadata is { id: 'string of numbers', name: 'string', email: 'string of email' }
      User.findByFacebookId fbUserMetadata.id
      .then (user) ->
        if user?
          session.existingUserLogin = true
          return cb.fulfill user
        User.findByEmail fbUserMetadata.email.toLowerCase()
        .then (user) ->
          if user?
            session.existingUserLogin = true
            user.facebookId = fbUserMetadata.id
            user.verified = true
            user.save()
            return cb.fulfill user
          user = new User
            name: fbUserMetadata.name
            email: fbUserMetadata.email.toLowerCase()
            facebookId: fbUserMetadata.id
            verified: true
          Q.ninvoke user, 'save'
          .then (user) -> cb.fulfill user
      .catch (err) -> cb.fulfill [err.message]
      cb
    redirectPath: (req, res) ->
      '/account/afterFacebookLogin' + if req.query.redirectTo? then "?redirectTo=#{req.query.redirectTo}" else ""
  everyauth.password.configure
    logoutPath: '/account/logout'
    loginWith: "email"
    getLoginPath: "/account/login"
    postLoginPath: "/account/login"
    loginSuccessRedirect: "/"
    registerSuccessRedirect: "/account/registered"
    getRegisterPath: "/account/register"
    postRegisterPath: "/account/register"
    registerView: path.join app.get('views'), "account/register.jade"
    loginView: path.join app.get('views'), "account/login.jade"
    loginLocals: (req, res, cb) ->
      locals =
        if req.query.redirectTo?
          redirectTo: "?redirectTo=#{req.query.redirectTo}"
        else
          redirectTo: ''
      addRecaptcha = ->
        recaptcha = new Recaptcha config.recaptcha.publicKey, config.recaptcha.privateKey, true
        locals.recaptchaForm = recaptcha.toHTML()
      if req.session.carefulLogin
        addRecaptcha()
        return setImmediate -> cb null, locals
      else if req.body.email?
        User.findByEmail req.body.email
        .then (user) ->
          if user?.carefulLogin()
            req.session.carefulLogin = true
            addRecaptcha()
          cb null, locals
        .catch (err) -> cb err
      else
        setImmediate -> cb null, locals
    extractLoginPassword: (req, res) ->
      if req.session.carefulLogin
        data =
          remoteip: req.connection.remoteAddress
          captchaChallenge: req.body.recaptcha_challenge_field
          captchaResponse: req.body.recaptcha_response_field
          password: req.body.password
        [req.body.email, data]
      else
        [req.body.email, req.body.password]
    authenticate: (email, password) ->
      cb = @Promise()
      errors = []
      errors.push "Informe o e-mail" unless email? and email isnt ''
      errors.push "Informe a senha" unless password? and password isnt ''
      return cb.fulfill errors if errors.length isnt 0
      User.findByEmail email.toLowerCase()
      .then (user) ->
        return cb.fulfill [error] if error?
        return cb.fulfill ['Login falhou'] unless user?
        validatePassword = ->
          p = if typeof password is 'string' then password else password.password
          user.verifyPassword p
          .then (success) ->
            if success
              cb.fulfill user
            else
              cb.fulfill ["Login falhou"]
        if DEBUG or !user.carefulLogin()
          validatePassword()
        else
          Q.fcall ->
            if typeof password.remoteip?
              recaptcha = new Recaptcha config.recaptcha.publicKey, config.recaptcha.privateKey, {remoteip: password.remoteip, challenge: password.captchaChallenge, response: password.captchaResponse}, true
              d = Q.defer()
              recaptcha.verify (success, errorCode) ->
                error = if success then null else "O valor informado para a imagem está errado."
                d.resolve [error, success]
              d.promise
            else
              ["O valor da imagem não foi informado.", false]
          .spread (error, success) ->
            if !success
              cb.fulfill [error]
            else
              validatePassword()
      .catch (err) -> cb.fulfill [err.message]
      cb
    respondToLoginSucceed: (res, user, data) ->
      return unless user?
      if data.req.query.redirectTo?
        @redirect res, data.req.query.redirectTo
      else
        @redirect res, '/'
    #performRedirect: (res, location) -> res.redirect location, 302
    registerLocals: (req, res) ->
      recaptcha = new Recaptcha config.recaptcha.publicKey, config.recaptcha.privateKey, true
      states: values.states
      userParams: req.body
      recaptchaForm: recaptcha.toHTML()
      redirectTo: if req.query.redirectTo? then "?redirectTo=#{req.query.redirectTo}" else ''
    validateRegistration: (newUserAttrs, errors) ->
      email = newUserAttrs.email.toLowerCase()
      password = newUserAttrs.password
      cb = @Promise()
      unless /^(?=(?:.*[A-z]){1})(?=(?:.*\d){1}).{8,}$/.test password
        errors.push "A senha não é forte."
        cb.fulfill errors
        return cb
      if email is config.superAdminEmail
        errors.push "E-mail já cadastrado."
        cb.fulfill errors
        return cb
      User.findByEmail email
      .then (user) ->
        errors.push "E-mail já cadastrado." if user?
        if DEBUG
          cb.fulfill errors
        else
          data =
            remoteip:  newUserAttrs.remoteip
            challenge: newUserAttrs.captchaChallenge
            response:  newUserAttrs.captchaResponse
          recaptcha = new Recaptcha config.recaptcha.publicKey, config.recaptcha.privateKey, data, true
          recaptcha.verify (success, errorCode) ->
            errors.push "Código incorreto." unless success
            cb.fulfill errors
      .catch (err) ->
        errors.push err
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
      user.save (error, user) ->
        cb.fulfill(if error? then [error] else user)
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
    respondToRegistrationSucceed: (req, res, user) ->
      user.sendMailConfirmRegistration req.query?.redirectTo
      .then => @redirect res, @registerSuccessRedirect() + if req.query.redirectTo? then "?redirectTo=#{req.query.redirectTo}" else ""
  
  everyauth.everymodule.findUserById (req, userId, cb) ->
    User.findById userId, (error, user) ->
      #console.log "found user: #{user}"
      cb error, user
  everyauth.everymodule.userPkey '_id'
