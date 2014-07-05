require './support/_specHelper'
User                      = require '../../app/models/user'
bcrypt                    = require 'bcrypt'
AccountResetPasswordPage  = require './support/pages/accountResetPasswordPage'
Q                         = require 'q'

describe 'Reset Password', ->
  user = resetKey = page = null
  describe 'Can reset password', ->
    before ->
      page = new AccountResetPasswordPage()
      cleanDB()
      .then ->
        user = generator.user.a()
        resetKey = user.createResetKey()
        Q.ninvoke user, 'save'
      .then -> page.visit user._id, resetKey
      .then -> page.setFieldsAs newPassword: 'newPassword1@', passwordVerify: 'newPassword1@'
      .then page.clickChangePasswordButton
    it 'is at the password changed page', -> page.currentUrl().should.become "http://localhost:8000/account/passwordChanged"
    it 'changed the user password', ->
      User.findByEmail user.email
      .then (foundUser) ->
        bcrypt.compareSync('newPassword1@', foundUser.passwordHash).should.be.true
    it 'deleted reset key', ->
      User.findByEmail user.email
      .then (foundUser) -> expect(foundUser.resetKey).to.be.undefined

  describe 'Shows error message if reset key not set', ->
    passwordHash = resetKey = null
    before ->
      page = new AccountResetPasswordPage()
      resetKey = 12345
      cleanDB()
      .then ->
        user = generator.user.a()
        passwordHash = user.passwordHash
        Q.ninvoke user, 'save'
      .then -> page.visit user._id, resetKey
      .then -> page.setFieldsAs newPassword: 'newPassword1@', passwordVerify: 'newPassword1@'
      .then page.clickChangePasswordButton
    it 'is at the reset password page', -> page.currentUrl().should.become "http://localhost:8000/account/resetPassword?_id=#{user._id}&resetKey=#{resetKey}"
    it 'did not change the user password', ->
      User.findByEmail user.email
      .then (foundUser) -> foundUser.passwordHash.should.equal passwordHash
    it 'shows an error message', -> page.errorMsg().should.become "Não foi possível trocar a senha."

  describe 'Shows error message if reset key is wrong', ->
    passwordHash = resetKey = null
    before ->
      page = new AccountResetPasswordPage()
      cleanDB()
      .then ->
        user = generator.user.a()
        passwordHash = user.passwordHash
        resetKey = user.createResetKey()
        Q.ninvoke user, 'save'
      .then -> page.visit user._id, resetKey + '123'
      .then -> page.setFieldsAs newPassword: 'newPassword1@', passwordVerify: 'newPassword1@'
      .then page.clickChangePasswordButton
    it 'is at the reset password page', -> page.currentUrl().should.become "http://localhost:8000/account/resetPassword?_id=#{user._id}&resetKey=#{resetKey}123"
    it 'did not change the user password', ->
      User.findByEmail user.email
      .then (foundUser) -> foundUser.passwordHash.should.equal passwordHash
    it 'shows an error message', -> page.errorMsg (msg) -> msg.should.equal "Não foi possível trocar a senha."
