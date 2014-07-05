require './support/_specHelper'
User      = require '../../app/models/user'
bcrypt    = require 'bcrypt'
config    = require '../../app/helpers/config'
Page      = require './support/pages/accountRegisterPage'
Q         = require 'q'

describe 'Register', ->
  userA = page = null
  before ->
    page = new Page()
    cleanDB().then ->
      userA = generator.user.a()
      userA.save()
      whenServerLoaded

  describe "Can't register as super admin", ->
    before ->
      page.clearCookies()
      .then page.visit
      .then page.clickManualEntry
      .then -> page.setFieldsAs name: "Some Person", email: config.superAdminEmail, password: "P@ssw0rd12", passwordVerify: 'P@ssw0rd12', deliveryZIP: '', termsOfUse: true
      .then page.clickRegisterButton
    it 'shows the register failed message', test -> page.errors().should.become 'E-mail já cadastrado.'
    it 'is at the register page', test -> page.currentUrl().should.become "http://localhost:8000/account/register"
    it 'does not show logout link', test -> page.logoutLinkExists().should.eventually.be.false
    it 'does not show admin link', test -> page.adminLinkExists().should.eventually.be.false

  describe 'Must supply name, email and password or form is not submitted', ->
    before ->
      page.clearCookies()
      .then page.visit
      .then page.clickManualEntry
      .then page.clickRegisterButton
    it 'does not show the register failed message', test -> page.hasErrors (itHas) -> expect(itHas).to.be.false
    it 'is at the register page', test -> page.currentUrl().should.become "http://localhost:8000/account/register"
    it 'Required messages are shown', test ->
      Q.all [
        page.emailRequired().should.become "Informe seu e-mail."
        page.passwordRequired().should.become "Informe uma senha correta."
        page.nameRequired().should.become "Informe seu nome."
      ]
  
  describe "Can't register successfully with existing email information", ->
    before ->
      page.clearCookies()
      .then page.visit
      .then page.clickManualEntry
      .then -> page.setFieldsAs name: "Some Person", email: userA.email, password: "P@ssw0rd12", passwordVerify: 'P@ssw0rd12', deliveryZIP: '', termsOfUse: true
      .then page.clickRegisterButton
    it 'shows the register failed message', test -> page.errors().should.become 'E-mail já cadastrado.'
    it 'is at the register page', test -> page.currentUrl().should.become "http://localhost:8000/account/register"
    it 'does not show logout link', test -> page.logoutLinkExists().should.eventually.be.false
    it 'does not show admin link', test -> page.adminLinkExists().should.eventually.be.false

  describe "Can't register successfully with weak password", ->
    before ->
      page.clearCookies()
      .then page.visit
      .then page.clickManualEntry
      .then -> page.setFieldsAs name: "Some Person", email: 'anothermailadd@email.com', password: "pass", passwordVerify: 'pass', termsOfUse: true
      .then page.clickRegisterButton
    it 'is at the register page', test -> page.currentUrl().should.become "http://localhost:8000/account/register"
    it 'does not show logout link', test -> page.logoutLinkExists().should.eventually.be.false
    it 'does not show admin link', test -> page.adminLinkExists().should.eventually.be.false
    it 'Shows invalid password message', test -> page.passwordRequired().should.become "Informe uma senha correta."

  describe 'Can register successfully with correct information', ->
    before ->
      page.clearCookies()
      .then page.visit
      .then page.clickManualEntry
      .then -> page.setFieldsAs name: "Some Person", email: "some@email.com", password: "P@ssw0rd12", isSeller: false, passwordVerify: 'P@ssw0rd12', deliveryStreet: 'Rua A, 23', deliveryStreet2: 'ap 21', deliveryCity: 'Sao Paulo', deliveryState: 'SP', phoneNumber: '4567-9877', deliveryZIP: '01234-567', termsOfUse: true
      .then page.clickRegisterButton
    it 'does not show the register failed message', test -> page.hasErrors().should.eventually.be.false
    it 'is at the registered welcome page', test -> page.currentUrl().should.become "http://localhost:8000/account/registered"
    it 'does not show login link', test -> page.loginLinkExists().should.eventually.be.false
    it 'shows logout link', test -> page.logoutLinkExists().should.eventually.be.true
    it 'does not show admin link', test -> page.adminLinkExists().should.eventually.be.false
    it 'shows user name', test -> page.userGreeting().should.become "Some Person"
    it 'is saved on database', test ->
      User.findByEmail "some@email.com", (error, user) ->
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
  
  describe 'Can register as seller successfully with correct information', ->
    before ->
      page.clearCookies()
      .then page.visit
      .then page.clickManualEntry
      .then -> page.setFieldsAs name: "Some Person", email: "someother@email.com", password: "P@ssw0rd12", isSeller: true, passwordVerify: 'P@ssw0rd12', deliveryZIP: '', termsOfUse: true
      .then page.clickRegisterButton
    it 'is a seller', test -> User.findByEmail("someother@email.com").then (user) -> user.isSeller.should.be.true
    it 'shows the admin link', test -> page.adminLinkExists().should.eventually.be.true
