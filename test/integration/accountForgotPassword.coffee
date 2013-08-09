require './support/_specHelper'
User     = require '../../app/models/user'
bcrypt   = require 'bcrypt'
AccountForgotPasswordPage = require './support/pages/accountForgotPasswordPage'

describe 'Account Forgot password', ->
  user = page = null
  before (done) -> whenServerLoaded done

  describe 'Can request password reset', ->
    before (done) ->
      page = new AccountForgotPasswordPage()
      cleanDB (error) ->
        return done error if error
        user = generator.user.a()
        user.save()
        page.visit ->
          page.setEmail user.email
          page.clickRequestPasswordReset done
    it 'is at the password request sent page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/account/passwordResetSent"
        done()
    it 'set reset key', (done) ->
      User.findByEmail user.email, (error, foundUser) ->
        return done error if error
        foundUser.resetKey.should.not.be.undefined
        done()
