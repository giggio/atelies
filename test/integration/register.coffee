require './support/_specHelper'
User     = require '../../app/models/user'
bcrypt   = require 'bcrypt'

describe 'Register', ->
  userA = browser = page = null
  before (done) ->
    browser = newBrowser()
    page = browser.registerPage
    cleanDB (error) ->
      return done error if error
      userA = generator.user.a()
      userA.save()
      whenServerLoaded done
  after -> browser.destroy()

  describe 'Must supply name, email and password or form is not submitted', ->
    before (done) ->
      page.visit (error) ->
        return done error if error
        page.clickRegisterButton done
    it 'does not show the register failed message', ->
      expect(page.errors()).to.equal ''
    it 'is at the register page', ->
      expect(browser.location.toString()).to.equal "http://localhost:8000/account/register"
    it 'Required messages are shown', ->
      expect(page.emailRequired()).to.equal "Informe seu e-mail."
      expect(page.passwordRequired()).to.equal "Informe uma senha correta."
      expect(page.nameRequired()).to.equal "Informe seu nome."

  describe 'Can register successfully with correct information', ->
    before (done) ->
      page.visit (error) ->
        return done error if error
        page.setFieldsAs name: "Some Person", email: "some@email.com", password: "P@ssw0rd12", isSeller: false, passwordVerify: 'P@ssw0rd12', deliveryStreet: 'Rua A, 23', deliveryStreet2: 'ap 21', deliveryCity: 'Sao Paulo', deliveryState: 'SP', phoneNumber: '4567-9877', deliveryZIP: '01234-567', termsOfUse: true
        page.clickRegisterButton done
    it 'does not show the register failed message', ->
      expect(page.errors()).to.equal ''
    it 'is at the home page', ->
      expect(browser.location.toString()).to.equal "http://localhost:8000/"
    it 'does not show login link', ->
      expect(page.loginLinkExists()).to.be.false
    it 'shows logout link', ->
      expect(page.logoutLinkExists()).to.be.true
    it 'does not show admin link', ->
      expect(page.adminLinkExists()).to.be.false
    it 'shows user name', ->
      expect(page.userGreeting()).to.equal "Some Person"
    it 'is saved on database', (done) ->
      User.findByEmail "some@email.com", (error, user) ->
        return done error if error
        expect(user).not.to.be.null
        expect(user.name).to.equal "Some Person"
        expect(user.isSeller).to.be.false
        bcrypt.compareSync('P@ssw0rd12', user.passwordHash).should.be.true
        user.phoneNumber.should.equal '4567-9877'
        deliveryAddress = user.deliveryAddress
        deliveryAddress.state.should.equal 'SP'
        deliveryAddress.street.should.equal 'Rua A, 23'
        deliveryAddress.street2.should.equal 'ap 21'
        deliveryAddress.city.should.equal 'Sao Paulo'
        deliveryAddress.zip.should.equal '01234-567'
        done()
  
  describe 'Can register as seller successfully with correct information', ->
    before (done) ->
      browser = newBrowser browser
      page = browser.registerPage
      page.visit (error) ->
        return done error if error
        page.setFieldsAs name: "Some Person", email: "someother@email.com", password: "P@ssw0rd12", isSeller: true, passwordVerify: 'P@ssw0rd12', deliveryZIP: '', termsOfUse: true
        page.clickRegisterButton done
    it 'is a seller', (done) ->
      User.findByEmail "someother@email.com", (error, user) ->
        return done error if error
        expect(user).not.to.be.null
        expect(user.isSeller).to.be.true
        done()
    it 'shows the admin link', ->
      expect(page.adminLinkExists()).to.be.true
  
  describe "Can't register successfully with existing email information", ->
    before (done) ->
      browser = newBrowser browser
      page = browser.registerPage
      page.visit (error) ->
        return done error if error
        page.setFieldsAs name: "Some Person", email: userA.email, password: "P@ssw0rd12", passwordVerify: 'P@ssw0rd12', deliveryZIP: '', termsOfUse: true
        page.clickRegisterButton done
    it 'shows the register failed message', ->
      expect(page.errors()).to.equal 'E-mail já cadastrado.'
    it 'is at the register page', ->
      expect(browser.location.toString()).to.equal "http://localhost:8000/account/register"
    it 'does shows login link', ->
      expect(page.loginLinkExists()).to.be.true
    it 'does not show logout link', ->
      expect(page.logoutLinkExists()).to.be.false
    it 'does not show admin link', ->
      expect(page.adminLinkExists()).to.be.false

  describe "Can't register successfully with weak password", ->
    before (done) ->
      browser = newBrowser browser
      page = browser.registerPage
      page.visit (error) ->
        return done error if error
        page.setFieldsAs name: "Some Person", email: 'anothermailadd@email.com', password: "pass", passwordVerify: 'pass', termsOfUse: true
        page.clickRegisterButton done
    it 'is at the register page', ->
      expect(browser.location.toString()).to.equal "http://localhost:8000/account/register"
    it 'does shows login link', ->
      expect(page.loginLinkExists()).to.be.true
    it 'does not show logout link', ->
      expect(page.logoutLinkExists()).to.be.false
    it 'does not show admin link', ->
      expect(page.adminLinkExists()).to.be.false
    it 'Shows invalid password message', ->
      expect(page.passwordRequired()).to.equal "Informe uma senha correta."
