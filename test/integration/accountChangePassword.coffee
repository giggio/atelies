require './support/_specHelper'
User     = require '../../app/models/user'
bcrypt   = require 'bcrypt'
Page     = require './support/pages/changePasswordPage'

describe 'Change Password', ->
  user = page = null
  before (done) ->
    page = new Page()
    whenServerLoaded done

  describe 'Can change password', ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        user = generator.user.a()
        user.save()
        page.loginFor user._id, ->
          page.visit ->
            page.setFieldsAs password: user.password, newPassword: 'newPassword1@', passwordVerify: 'newPassword1@'
            page.clickChangePasswordButton done
    it 'does not show the change password failed message', (done) ->
      page.hasErrors (itHas) =>
        itHas.should.be.false
        done()
    it 'is at the password changed page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/account/passwordChanged"
        done()
    it 'changed the user password', (done) ->
      User.findByEmail user.email, (error, foundUser) ->
        return done error if error
        bcrypt.compareSync('newPassword1@', foundUser.passwordHash).should.be.true
        done()

  describe 'Can\'t change invalid password', ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        user = generator.user.a()
        user.save()
        page.loginFor user._id, ->
          page.visit ->
            page.setFieldsAs password: "#{user.password}other", newPassword: 'newPassword1@', passwordVerify: 'newPassword1@'
            page.clickChangePasswordButton done
    it 'shows the invalid password message', (done) ->
      page.errors (errors) =>
        expect(errors).to.equal 'Senha inválida.'
        done()
    it 'is at the change password page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/account/changePassword"
        done()
    it 'did not changed the user password', (done) ->
      User.findByEmail user.email, (error, foundUser) ->
        return done error if error
        bcrypt.compareSync('newPassword', foundUser.passwordHash).should.be.false
        bcrypt.compareSync(user.password, foundUser.passwordHash).should.be.true
        done()

  describe 'Can\'t change password if verification fails', ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        user = generator.user.a()
        user.save()
        page.loginFor user._id, ->
          page.visit ->
            page.setFieldsAs password: user.password, newPassword: 'newPassword1@', passwordVerify: 'otherPassword'
            page.clickChangePasswordButton done
    it 'does not show the login failed message', (done) ->
      page.passwordVerifyMessage (message) =>
        expect(message).to.equal 'A senha não confere.'
        done()
    it 'is at the change password page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/account/changePassword"
        done()
    it 'did not changed the user password', (done) ->
      User.findByEmail user.email, (error, foundUser) ->
        return done error if error
        bcrypt.compareSync('newPassword', foundUser.passwordHash).should.be.false
        bcrypt.compareSync(user.password, foundUser.passwordHash).should.be.true
        done()
