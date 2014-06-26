require './support/_specHelper'
User                      = require '../../app/models/user'
bcrypt                    = require 'bcrypt'
AccountForgotPasswordPage = require './support/pages/accountForgotPasswordPage'
Q                         = require 'q'

describe 'Account Forgot password', ->
  user = page = null
  before whenServerLoaded

  describe 'Can request password reset', ->
    before ->
      page = new AccountForgotPasswordPage()
      cleanDB()
      .then ->
        user = generator.user.a()
        user.save()
      .then page.visit
      .then -> page.setEmail user.email.toUpperCase()
      .then page.clickRequestPasswordReset
    it 'is at the password request sent page', ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/account/passwordResetSent"
    it 'set reset key', ->
      User.findByEmail user.email
      .then (foundUser) ->
        foundUser.resetKey.should.not.be.undefined
