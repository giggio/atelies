path          = require "path"
everyauth     = require 'everyauth'
User          = require '../models/user'
values        = require './values'
Recaptcha     = require 'librecaptcha'
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
      promise = @Promise()
      #fbUserMetadata is { id: 'string of numbers', name: 'string', email: 'string of email' }
      User.findByFacebookId fbUserMetadata.id
      .then (user) ->
        if user?
          session.existingUserLogin = true
          return promise.fulfill user
        User.findByEmail fbUserMetadata.email.toLowerCase()
        .then (user) ->
          if user?
            session.existingUserLogin = true
            user.facebookId = fbUserMetadata.id
            user.verified = true
            user.save()
            return promise.fulfill user
          user = new User
            name: fbUserMetadata.name
            email: fbUserMetadata.email.toLowerCase()
            facebookId: fbUserMetadata.id
            verified: true
          Q.ninvoke user, 'save'
          .then (user) -> promise.fulfill user
      .catch (err) -> promise.fulfill [err.message]
      promise
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
        recaptcha = new Recaptcha public_key: config.recaptcha.publicKey, private_key: config.recaptcha.privateKey
        locals.recaptchaForm = recaptcha.generate()
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
      promise = @Promise()
      errors = []
      errors.push "Informe o e-mail" unless email? and email isnt ''
      errors.push "Informe a senha" unless password? and password isnt ''
      return promise.fulfill errors if errors.length isnt 0
      User.findByEmail email.toLowerCase()
      .then (user) ->
        return promise.fulfill [error] if error?
        return promise.fulfill ['Login falhou'] unless user?
        validatePassword = ->
          p = if typeof password is 'string' then password else password.password
          user.verifyPassword p
          .then (success) ->
            if success
              promise.fulfill user
            else
              promise.fulfill ["Login falhou"]
        if DEBUG or !user.carefulLogin()
          validatePassword()
        else
          Q.fcall ->
            if typeof password.remoteip?
              recaptcha = new Recaptcha public_key: config.recaptcha.publicKey, private_key: config.recaptcha.privateKey
              d = Q.defer()
              recaptcha.verify {remoteip: password.remoteip, challenge: password.captchaChallenge, response: password.captchaResponse}, (err) ->
                error = if err? then "O valor informado para a imagem está errado." else null
                d.resolve error
              d.promise
            else
              "O valor da imagem não foi informado."
          .then (recaptchaError) ->
            if recaptchaError?
              promise.fulfill [recaptchaError]
            else
              validatePassword()
      .catch (err) -> promise.fulfill [err.message]
      promise
    respondToLoginSucceed: (res, user, data) ->
      return unless user?
      data.req.session.carefulLogin = false
      if data.req.query.redirectTo?
        @redirect res, data.req.query.redirectTo
      else
        @redirect res, '/'
    #performRedirect: (res, location) -> res.redirect location, 302
    registerLocals: (req, res) ->
      recaptcha = new Recaptcha public_key: config.recaptcha.publicKey, private_key: config.recaptcha.privateKey
      states: values.states
      userParams: req.body
      recaptchaForm: recaptcha.generate()
      redirectTo: if req.query.redirectTo? then "?redirectTo=#{req.query.redirectTo}" else ''
    validateRegistration: (newUserAttrs, errors) ->
      email = newUserAttrs.email.toLowerCase()
      password = newUserAttrs.password
      promise = @Promise()
      unless /^(?=(?:.*[A-z]){1})(?=(?:.*\d){1}).{8,}$/.test password
        errors.push "A senha não é forte."
        promise.fulfill errors
        return promise
      if email is config.superAdminEmail
        errors.push "E-mail já cadastrado."
        promise.fulfill errors
        return promise
      User.findByEmail email
      .then (user) ->
        errors.push "E-mail já cadastrado." if user?
        if DEBUG
          promise.fulfill errors
        else
          data =
            remoteip:  newUserAttrs.remoteip
            challenge: newUserAttrs.captchaChallenge
            response:  newUserAttrs.captchaResponse
          recaptcha = new Recaptcha public_key: config.recaptcha.publicKey, private_key: config.recaptcha.privateKey
          recaptcha.verify data, (err) ->
            errors.push "Código incorreto." if err?
            promise.fulfill errors
      .catch (err) ->
        errors.push err
        promise.fulfill errors
      promise
    registerUser: (newUserAttrs) ->
      promise = @Promise()
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
        promise.fulfill(if error? then [error] else user)
      promise

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
  
  #used by everyauth:
  everyauth.everymodule.findUserById (req, userId, cb) ->
    User.findById userId, (error, user) ->
      #console.log "found user: #{user}"
      cb error, user
  #used by everyauth:
  everyauth.everymodule.userPkey '_id'
