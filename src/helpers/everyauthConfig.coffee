everyauth     = require 'everyauth'
User          = require '../models/user'

exports.configure = ->
  everyauth.password.configure
    loginWith: "email"
    getLoginPath: "/login"
    postLoginPath: "/login"
    loginSuccessRedirect: "/"
    registerSuccessRedirect: "/"
    getRegisterPath: "/register"
    postRegisterPath: "/register"
    registerView: "register.jade"
    loginView: "login.jade"
    loginLocals: (req, res) ->
    authenticate: (email, password) ->
      errors = []
      errors.push "Missing login" unless email?
      errors.push "Missing password" unless password?
      return errors if errors.length isnt 0
      cb = @Promise()
      User.findByEmail email, (error, user) ->
        return cb([error]) if error?
        cb.fulfill(if user?.password is password then user else ["Login falhou"])
      cb
    registerLocals: (req, res) ->
    validateRegistration: (newUserAttrs, errors) ->
      email = newUserAttrs.login
      cb = @Promise()
      User.findByEmail email, (error, user) ->
        return cb([error]) if error?
        errors.push "Email já cadastrado" if user?
        cb.fulfill errors
      cb
    registerUser: (newUserAttrs) ->
      cb = @Promise()
      email = newUserAttrs[@loginKey()]
      user = new User newUserAttrs
      user.save (error, user) -> cb.fulfill(if error? then [error] else user)
      cb
    extractExtraRegistrationParams: (req) ->
      name: req.body.name
  
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
