require './support/_specHelper'

describe 'Login', ->
  userA = userB = userSellerC = browser = page = null
  before (done) ->
    browser = newBrowser()
    page = browser.loginPage
    cleanDB (error) ->
      return done error if error
      userA = generator.user.a()
      userA.save()
      userB = generator.user.b()
      userB.save()
      userSellerC = generator.user.c()
      userSellerC.save()
      whenServerLoaded done
  after -> browser.destroy()

  describe 'Login in with unknown user fails', ->
    before (done) ->
      page.visit (error) ->
        return done error if error
        page.setFieldsAs email:"someinexistentuser@a.com", password:"abcdasklfadsj"
        page.clickLoginButton done
    it 'shows login link', ->
      expect(page.loginLinkExists()).to.be.true
    it 'does not show logout link', ->
      expect(page.logoutLinkExists()).to.be.false
    it 'shows the login failed message', ->
      expect(page.errors()).to.equal 'Login falhou'
    it 'is at the login page', ->
      expect(browser.location.toString()).to.equal "http://localhost:8000/account/login"
    it 'does not show admin link', ->
      expect(page.adminLinkExists()).to.be.false

  describe 'Must supply name and password or form is not submitted', ->
    before (done) ->
      page.visit (error) ->
        return done error if error
        page.clickLoginButton done
    it 'does not show the login failed message', ->
      expect(page.errors()).to.equal ''
    it 'is at the login page', ->
      expect(browser.location.toString()).to.equal "http://localhost:8000/account/login"
    it 'Required messages are shown', ->
      expect(page.emailRequired()).to.equal "Informe seu e-mail."
      expect(page.passwordRequired()).to.equal "Informe sua senha."

  describe 'Can login successfully with regular user', ->
    before (done) ->
      page.visit (error) ->
        return done error if error
        page.setFieldsAs userA
        page.clickLoginButton done
    it 'does not show the login failed message', ->
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
      expect(page.userGreeting()).to.equal userA.name

  describe 'Trying to access admin page redirects to login with redirectTo query string set', ->
    before (done) ->
      browser = newBrowser browser
      browser.visit "http://localhost:8000/admin", done
    it 'is at the login page', ->
      expect(browser.location.toString()).to.equal "http://localhost:8000/account/login?redirectTo=/admin"

  xdescribe 'Login with admin user redirects to original url', -> #doesnt work on zombie...
    before (done) ->
      browser = newBrowser browser
      page = browser.loginPage
      browser.visit "http://localhost:8000/admin", (error) ->
        return done error if error?
        page.setFieldsAs userSellerC
        page.clickLoginButton done
    it 'is at the admin page', ->
      expect(browser.location.toString()).to.equal "http://localhost:8000/admin"

  describe 'Three errors on login does not show captcha if user does not exist', ->
    it 'does not show login link', (done) ->
      browser = newBrowser browser
      page = browser.loginPage
      page.visit (error) ->
        return done error if error
        page.setFieldsAs email:"someinexistentuser@a.com", password:"abcdasklfadsj"
        page.clickLoginButton ->
          page.setFieldsAs email:"someinexistentuser@a.com", password:"abcdasklfadsj"
          page.clickLoginButton ->
            page.setFieldsAs email:"someinexistentuser@a.com", password:"abcdasklfadsj"
            page.clickLoginButton ->
              expect(page.showsCaptcha()).to.be.false
              done()

  describe 'Three errors on login shows captcha if user exists', ->
    it 'shows login link', ->
      browser = newBrowser browser
      page = browser.loginPage
      page.visit (error) ->
        return done error if error
        page.setFieldsAs email:userA.email, password:"abcdasklfadsj"
        page.clickLoginButton ->
          page.setFieldsAs email:userA.email, password:"abcdasklfadsj"
          page.clickLoginButton ->
            page.setFieldsAs email:userA.email, password:"abcdasklfadsj"
            page.clickLoginButton ->
              expect(page.showsCaptcha()).to.be.true
              done()
