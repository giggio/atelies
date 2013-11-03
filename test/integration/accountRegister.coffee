require './support/_specHelper'
User     = require '../../app/models/user'
bcrypt   = require 'bcrypt'
config   = require '../../app/helpers/config'
Page     = require './support/pages/registerPage'

describe 'Register', ->
  userA = page = null
  before (done) ->
    page = new Page()
    cleanDB (error) ->
      return done error if error
      userA = generator.user.a()
      userA.save()
      whenServerLoaded done

  describe "Can't register as super admin", ->
    before (done) ->
      page.clearCookies =>
        page.visit ->
          page.clickManualEntry ->
            page.setFieldsAs name: "Some Person", email: config.superAdminEmail, password: "P@ssw0rd12", passwordVerify: 'P@ssw0rd12', deliveryZIP: '', termsOfUse: true, =>
              page.clickRegisterButton done
    it 'shows the register failed message', (done) ->
      page.errors (errors) =>
        expect(errors).to.equal 'E-mail já cadastrado.'
        done()
    it 'is at the register page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/account/register"
        done()
    it 'does shows login link', (done) ->
      page.loginLinkExists (itDoes) ->
        expect(itDoes).to.be.true
        done()
    it 'does not show logout link', (done) ->
      page.logoutLinkExists (itDoes) ->
        expect(itDoes).to.be.false
        done()
    it 'does not show admin link', (done) ->
      page.adminLinkExists (itDoes) ->
        expect(itDoes).to.be.false
        done()

  describe 'Must supply name, email and password or form is not submitted', ->
    before (done) ->
      page.clearCookies =>
        page.visit ->
          page.clickManualEntry ->
            page.clickRegisterButton done
    it 'does not show the register failed message', (done) ->
      page.hasErrors (itHas) ->
        expect(itHas).to.be.false
        done()
    it 'is at the register page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/account/register"
        done()
    it 'Required messages are shown', (done) ->
      page.emailRequired (emailRequired) ->
        emailRequired.should.equal "Informe seu e-mail."
        page.passwordRequired (passwordRequired) ->
          expect(passwordRequired).to.equal "Informe uma senha correta."
          page.nameRequired (nameRequired) ->
            expect(nameRequired).to.equal "Informe seu nome."
            done()
  
  describe "Can't register successfully with existing email information", ->
    before (done) ->
      page.clearCookies =>
        page.visit ->
          page.clickManualEntry ->
            page.setFieldsAs name: "Some Person", email: userA.email, password: "P@ssw0rd12", passwordVerify: 'P@ssw0rd12', deliveryZIP: '', termsOfUse: true, =>
              page.clickRegisterButton done
    it 'shows the register failed message', (done) ->
      page.errors (errors) ->
        expect(errors).to.equal 'E-mail já cadastrado.'
        done()
    it 'is at the register page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/account/register"
        done()
    it 'does show login link', (done) ->
      page.loginLinkExists (itDoes) ->
        expect(itDoes).to.be.true
        done()
    it 'does not show logout link', (done) ->
      page.logoutLinkExists (itDoes) ->
        expect(itDoes).to.be.false
        done()
    it 'does not show admin link', (done) ->
      page.adminLinkExists (itDoes) ->
        expect(itDoes).to.be.false
        done()

  describe "Can't register successfully with weak password", ->
    before (done) ->
      page.clearCookies =>
        page.visit ->
          page.clickManualEntry ->
            page.setFieldsAs name: "Some Person", email: 'anothermailadd@email.com', password: "pass", passwordVerify: 'pass', termsOfUse: true, =>
              page.clickRegisterButton done
    it 'is at the register page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/account/register"
        done()
    it 'does show login link', (done) ->
      page.loginLinkExists (itDoes) ->
        expect(itDoes).to.be.true
        done()
    it 'does not show logout link', (done) ->
      page.logoutLinkExists (itDoes) ->
        expect(itDoes).to.be.false
        done()
    it 'does not show admin link', (done) ->
      page.adminLinkExists (itDoes) ->
        expect(itDoes).to.be.false
        done()
    it 'Shows invalid password message', (done) ->
      page.passwordRequired (passwordRequired) ->
        expect(passwordRequired).to.equal "Informe uma senha correta."
        done()

  describe 'Can register successfully with correct information', ->
    before (done) ->
      page.clearCookies =>
        page.visit ->
          page.clickManualEntry ->
            page.setFieldsAs name: "Some Person", email: "some@email.com", password: "P@ssw0rd12", isSeller: false, passwordVerify: 'P@ssw0rd12', deliveryStreet: 'Rua A, 23', deliveryStreet2: 'ap 21', deliveryCity: 'Sao Paulo', deliveryState: 'SP', phoneNumber: '4567-9877', deliveryZIP: '01234-567', termsOfUse: true, =>
              page.clickRegisterButton done
    it 'does not show the register failed message', (done) ->
      page.hasErrors (itHas) ->
        expect(itHas).to.be.false
        done()
    it 'is at the registered welcome page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/account/registered"
        done()
    it 'does not show login link', (done) ->
      page.loginLinkExists (itDoes) ->
        expect(itDoes).to.be.false
        done()
    it 'shows logout link', (done) ->
      page.logoutLinkExists (itDoes) ->
        expect(itDoes).to.be.true
        done()
    it 'does not show admin link', (done) ->
      page.adminLinkExists (itDoes) ->
        expect(itDoes).to.be.false
        done()
    it 'shows user name', (done) ->
      page.userGreeting (userGreeting) ->
        expect(userGreeting).to.equal "Some Person"
        done()
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
      page.clearCookies =>
        page.visit ->
          page.clickManualEntry ->
            page.setFieldsAs name: "Some Person", email: "someother@email.com", password: "P@ssw0rd12", isSeller: true, passwordVerify: 'P@ssw0rd12', deliveryZIP: '', termsOfUse: true, =>
              page.clickRegisterButton done
    it 'is a seller', (done) ->
      User.findByEmail "someother@email.com", (error, user) ->
        return done error if error
        expect(user).not.to.be.null
        expect(user.isSeller).to.be.true
        done()
    it 'shows the admin link', (done) ->
      page.adminLinkExists (itDoes) ->
        expect(itDoes).to.be.true
        done()
