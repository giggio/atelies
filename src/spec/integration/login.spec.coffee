zombie    = new require 'zombie'

describe 'Login', ->
  describe 'Login in with unknown user fails', ->
    browser = page = null
    beforeAll (done) ->
      browser = newBrowser()
      page = browser.loginPage
      cleanDB (error) ->
        return done error if error
        whenServerLoaded ->
          page.visit (error) ->
            return done error if error
            page.setFieldsAs email:"a@a.com", password:"abc"
            page.clickLoginButton done
    it 'shows the login failed message', ->
      expect(page.errors()).toBe 'Login falhou'
    it 'is at the login page', ->
      expect(browser.location.toString()).toBe "http://localhost:8000/login"
