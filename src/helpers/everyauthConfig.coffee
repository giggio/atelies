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
    User.findById userId, cb
  everyauth.everymodule.userPkey '_id'
