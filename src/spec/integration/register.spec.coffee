zombie    = new require 'zombie'

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
        page.setFieldsAs name: "Some Person", email: "some@email.com", password: "abc123"
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
