require './support/_specHelper'
User     = require '../../app/models/user'
bcrypt   = require 'bcrypt'
AccountResetPasswordPage = require './support/pages/accountResetPasswordPage'

describe 'Reset Password', ->
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

  describe 'Shows error message if reset key not set', ->
    passwordHash = resetKey = null
    before (done) ->
      page = new AccountResetPasswordPage()
      cleanDB (error) ->
        return done error if error
        user = generator.user.a()
        user.save()
        passwordHash = user.passwordHash
        resetKey = 12345
        page.visit user._id, resetKey, ->
          page.setFieldsAs newPassword: 'newPassword1@', passwordVerify: 'newPassword1@'
          page.clickChangePasswordButton done
    it 'is at the reset password page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/account/resetPassword?_id=#{user._id}&resetKey=#{resetKey}"
        done()
    it 'did not change the user password', (done) ->
      User.findByEmail user.email, (error, foundUser) ->
        return done error if error
        foundUser.passwordHash.should.equal passwordHash
        done()
    it 'shows an error message', (done) ->
      page.errorMsg (msg) ->
        msg.should.equal "Não foi possível trocar a senha."
        done()

  describe 'Shows error message if reset key is wrong', ->
    passwordHash = resetKey = null
    before (done) ->
      page = new AccountResetPasswordPage()
      cleanDB (error) ->
        return done error if error
        user = generator.user.a()
        resetKey = user.createResetKey()
        user.save()
        passwordHash = user.passwordHash
        page.visit user._id, resetKey + '123', ->
          page.setFieldsAs newPassword: 'newPassword1@', passwordVerify: 'newPassword1@'
          page.clickChangePasswordButton done
    it 'is at the reset password page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/account/resetPassword?_id=#{user._id}&resetKey=#{resetKey}123"
        done()
    it 'did not change the user password', (done) ->
      User.findByEmail user.email, (error, foundUser) ->
        return done error if error
        foundUser.passwordHash.should.equal passwordHash
        done()
    it 'shows an error message', (done) ->
      page.errorMsg (msg) ->
        msg.should.equal "Não foi possível trocar a senha."
        done()
