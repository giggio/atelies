require './support/_specHelper'
User     = require '../../app/models/user'
bcrypt   = require 'bcrypt'
AccountResetPasswordPage = require './support/pages/accountResetPasswordPage'

describe 'Change Password', ->
  user = page = null
  before (done) -> whenServerLoaded done

  describe 'Can reset password', ->
    before (done) ->
      page = new AccountResetPasswordPage()
      cleanDB (error) ->
        return done error if error
        user = generator.user.a()
        resetKey = user.createResetKey()
        user.save()
        page.visit user._id, resetKey, ->
          page.setFieldsAs newPassword: 'newPassword1@', passwordVerify: 'newPassword1@'
          page.clickChangePasswordButton done
    it 'is at the password changed page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/account/passwordChanged"
        done()
    it 'changed the user password', (done) ->
      User.findByEmail user.email, (error, foundUser) ->
        return done error if error
        bcrypt.compareSync('newPassword1@', foundUser.passwordHash).should.be.true
        done()
    it 'deleted reset key', (done) ->
      User.findByEmail user.email, (error, foundUser) ->
        return done error if error
        expect(foundUser.resetKey).to.be.undefined
        done()
