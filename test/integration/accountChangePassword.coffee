require './support/_specHelper'
User     = require '../../app/models/user'
bcrypt   = require 'bcrypt'
Page     = require './support/pages/accountChangePasswordPage'
Q        = require 'q'

describe 'Change Password', ->
  user = page = null
  before ->
    page = new Page()
    whenServerLoaded()

  describe 'Can change password', ->
    before ->
      cleanDB().then ->
        user = generator.user.a()
        user.save()
      .then -> page.loginFor user._id
      .then page.visit
      .then -> page.setFieldsAs password: user.password, newPassword: 'newPassword1@', passwordVerify: 'newPassword1@'
      .then page.clickChangePasswordButton
    it 'does not show the change password failed message', -> page.hasErrors().should.eventually.be.false
    it 'is at the password changed page', -> page.currentUrl().should.eventually.equal "http://localhost:8000/account/passwordChanged"
    it 'changed the user password', ->
      User.findByEmail user.email
      .then (foundUser) -> bcrypt.compareSync('newPassword1@', foundUser.passwordHash).should.be.true

  describe 'Can\'t change invalid password', ->
    before ->
      cleanDB().then ->
        user = generator.user.a()
        user.save()
      .then -> page.loginFor user._id
      .then page.visit
      .then -> page.setFieldsAs password: "#{user.password}other", newPassword: 'newPassword1@', passwordVerify: 'newPassword1@'
      .then page.clickChangePasswordButton
    it 'shows the invalid password message', -> page.errors().should.become 'Senha inválida.'
    it 'is at the change password page', -> page.currentUrl().should.become "http://localhost:8000/account/changePassword"
    it 'did not changed the user password', ->
      User.findByEmail user.email
      .then -> (foundUser) ->
        bcrypt.compareSync('newPassword', foundUser.passwordHash).should.be.false
        bcrypt.compareSync(user.password, foundUser.passwordHash).should.be.true

  describe 'Can\'t change password if verification fails', ->
    before ->
      cleanDB().then ->
        user = generator.user.a()
        user.save()
      .then -> page.loginFor user._id
      .then page.visit
      .then -> page.setFieldsAs password: user.password, newPassword: 'newPassword1@', passwordVerify: 'otherPassword'
      .then page.clickChangePasswordButton
    it 'does not show the login failed message', -> page.passwordVerifyMessage().should.become 'A senha não confere.'
    it 'is at the change password page', -> page.currentUrl().should.become "http://localhost:8000/account/changePassword"
    it 'did not changed the user password', ->
      User.findByEmail user.email
      .then -> (foundUser) ->
        bcrypt.compareSync('newPassword', foundUser.passwordHash).should.be.false
        bcrypt.compareSync(user.password, foundUser.passwordHash).should.be.true
