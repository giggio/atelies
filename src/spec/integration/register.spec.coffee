User     = require '../../models/user'

describe 'Login', ->
  userA = browser = page = null
  beforeAll (done) ->
    browser = newBrowser()
    page = browser.registerPage
    cleanDB (error) ->
      return done error if error
      userA = generator.user.a()
      userA.save()
      whenServerLoaded done
  afterAll -> browser.destroy()

  describe 'Must supply name, email and password or form is not submitted', ->
    beforeAll (done) ->
      page.visit (error) ->
        return done error if error
        page.clickRegisterButton done
    it 'does not show the register failed message', ->
      expect(page.errors()).toBe ''
    it 'is at the register page', ->
      expect(browser.location.toString()).toBe "http://localhost:8000/register"
    it 'Required messages are shown', ->
      expect(page.emailRequired()).toBe "Informe seu e-mail."
      expect(page.passwordRequired()).toBe "Informe sua senha."
      expect(page.nameRequired()).toBe "Informe seu nome."

  describe 'Can register successfully with correct information', ->
    beforeAll (done) ->
      page.visit (error) ->
        return done error if error
        page.setFieldsAs name: "Some Person", email: "some@email.com", password: "abc123", isSeller: false
        page.clickRegisterButton done
    it 'does not show the register failed message', ->
      expect(page.errors()).toBe ''
    it 'is at the home page', ->
      expect(browser.location.toString()).toBe "http://localhost:8000/"
    it 'does not show login link', ->
      expect(page.loginLinkExists()).toBeFalsy()
    it 'shows logout link', ->
      expect(page.logoutLinkExists()).toBeTruthy()
    it 'does not show admin link', ->
      expect(page.adminLinkExists()).toBeFalsy()
    it 'shows user name', ->
      expect(page.userGreeting()).toBe "Some Person"
    it 'is saved on database', (done) ->
      User.findByEmail "some@email.com", (error, user) ->
        return done error if error
        expect(user).not.toBeNull()
        expect(user.name).toBe "Some Person"
        expect(user.password).toBe "abc123"
        expect(user.isSeller).toBeFalsy()
        done()
  
  describe 'Can register as seller successfully with correct information', ->
    beforeAll (done) ->
      browser = newBrowser browser
      page = browser.registerPage
      page.visit (error) ->
        return done error if error
        page.setFieldsAs name: "Some Person", email: "someother@email.com", password: "abc123", isSeller: true
        page.clickRegisterButton done
    it 'is a seller', (done) ->
      User.findByEmail "someother@email.com", (error, user) ->
        return done error if error
        expect(user).not.toBeNull()
        expect(user.isSeller).toBeTruthy()
        done()
    it 'shows the admin link', ->
      expect(page.adminLinkExists()).toBeTruthy()
  
  describe "Can't register successfully with existing email information", ->
    beforeAll (done) ->
      browser = newBrowser browser
      page = browser.registerPage
      page.visit (error) ->
        return done error if error
        page.setFieldsAs name: "Some Person", email: userA.email, password: "abc123"
        page.clickRegisterButton done
    it 'shows the register failed message', ->
      expect(page.errors()).toBe 'E-mail já cadastrado.'
    it 'is at the register page', ->
      expect(browser.location.toString()).toBe "http://localhost:8000/register"
    it 'does shows login link', ->
      expect(page.loginLinkExists()).toBeTruthy()
    it 'does not show logout link', ->
      expect(page.logoutLinkExists()).toBeFalsy()
    it 'does not show admin link', ->
      expect(page.adminLinkExists()).toBeFalsy()
