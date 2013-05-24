require './support/_specHelper'
User     = require '../../app/models/user'
bcrypt   = require 'bcrypt'

describe 'Change Password', ->
  user = browser = page = null
  before (done) -> whenServerLoaded done
  after -> browser.destroy()

  describe 'Can change password', ->
    before (done) ->
      browser = newBrowser()
      page = browser.changePasswordPage
      cleanDB (error) ->
        return done error if error
        user = generator.user.a()
        user.save()
        browser.loginPage.navigateAndLoginWith user, ->
          page.visit (error) ->
            return done error if error
            page.setFieldsAs password: user.password, newPassword: 'newPassword', passwordVerify: 'newPassword'
            page.clickChangePasswordButton done
    it 'does not show the login failed message', ->
      expect(page.errors()).to.equal ''
    it 'is at the password changed page', ->
      expect(browser.location.toString()).to.equal "http://localhost:8000/account/passwordChanged"
    it 'changed the user password', (done) ->
      User.findByEmail user.email, (error, foundUser) ->
        return done error if error
        bcrypt.compareSync('newPassword', foundUser.passwordHash).should.be.true
        done()

  describe 'Can\'t change invalid password', ->
    before (done) ->
      browser = newBrowser()
      page = browser.changePasswordPage
      cleanDB (error) ->
        return done error if error
        user = generator.user.a()
        user.save()
        browser.loginPage.navigateAndLoginWith user, ->
          page.visit (error) ->
            return done error if error
            page.setFieldsAs password: "#{user.password}other", newPassword: 'newPassword', passwordVerify: 'newPassword'
            page.clickChangePasswordButton done
    it 'does not show the login failed message', ->
      expect(page.errors()).to.equal 'Senha inválida.'
    it 'is at the change password page', ->
      expect(browser.location.toString()).to.equal "http://localhost:8000/account/changePassword"
    it 'did not changed the user password', (done) ->
      User.findByEmail user.email, (error, foundUser) ->
        return done error if error
        bcrypt.compareSync('newPassword', foundUser.passwordHash).should.be.false
        bcrypt.compareSync(user.password, foundUser.passwordHash).should.be.true
        done()
