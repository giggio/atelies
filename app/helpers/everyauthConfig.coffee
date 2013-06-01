path          = require "path"
everyauth     = require 'everyauth'
User          = require '../models/user'

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
    validateRegistration: (newUserAttrs, errors) ->
      email = newUserAttrs.email.toLowerCase()
      cb = @Promise()
      User.findByEmail email, (error, user) ->
        return cb([error]) if error?
        errors.push "E-mail já cadastrado." if user?
        cb.fulfill errors
      cb
    registerUser: (newUserAttrs) ->
      cb = @Promise()
      newUserAttrs[@loginKey()] = newUserAttrs[@loginKey()].toLowerCase()
      password = newUserAttrs.password
      delete newUserAttrs.password
      user = new User newUserAttrs
      user.setPassword password
      user.save (error, user) -> cb.fulfill(if error? then [error] else user)
      cb
    extractExtraRegistrationParams: (req) ->
      name: req.body.name
      isSeller: req.body.isSeller?
  
  everyauth.everymodule.findUserById (req, userId, cb) ->
    User.findById userId, (error, user) ->
      #console.log "found user: #{user}"
      cb error, user
  everyauth.everymodule.userPkey '_id'

exports.preEveryAuthMiddlewareHack = ->
  (req, res, next) ->
    sess = req.session
    auth = sess.auth
    ea =
      loggedIn: auth?.loggedIn
    ea[k] = val for own k, val of auth
    if everyauth.enabled.password
      ea.password = ea.password || {}
      ea.password.loginFormFieldName = everyauth.password.loginFormFieldName()
      ea.password.passwordFormFieldName = everyauth.password.passwordFormFieldName()
    res.locals.everyauth = ea
    do next

exports.postEveryAuthMiddlewareHack = ->
  userAlias = everyauth.expressHelperUserAlias || "user"
  (req, res, next) ->
    res.locals.everyauth.user = req.user
    res.locals[userAlias] = req.user
    do next
