require './support/_specHelper'
Page = require './support/pages/loginPage'

describe 'Login', ->
  userA = userB = userSellerC = page = null
  before (done) ->
    page = new Page()
    cleanDB (error) ->
      return done error if error
      userA = generator.user.a()
      userA.save()
      userB = generator.user.b()
      userB.save()
      userSellerC = generator.user.c()
      userSellerC.save()
      whenServerLoaded done

  describe 'Login in with unknown user fails', ->
    before (done) ->
      page.visit ->
        page.setFieldsAs email:"someinexistentuser@a.com", password:"abcdasklfadsj"
        page.clickLoginButton done
    it 'shows login link', (done) ->
      page.loginLinkExists (itDoes) ->
        itDoes.should.be.true
        done()
    it 'does not show logout link', (done) ->
      page.logoutLinkExists (itDoes) ->
        itDoes.should.be.false
        done()
    it 'shows the login failed message', (done) ->
      page.errors (errors) ->
        errors.should.equal 'Login falhou'
        done()
    it 'is at the login page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/account/login"
        done()
    it 'does not show admin link', (done) ->
      page.adminLinkExists (itDoes) ->
        itDoes.should.be.false
        done()

  describe 'Must supply name and password or form is not submitted', ->
    before (done) ->
      page.visit ->
        page.clickLoginButton done
    it 'does not show the login failed message', (done) ->
      page.hasErrors (itHas) ->
        itHas.should.be.false
        done()
    it 'is at the login page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/account/login"
        done()
    it 'Required messages are shown', (done) ->
      page.emailRequired (emailRequired) ->
        emailRequired.should.equal "Informe seu e-mail."
        page.passwordRequired (passwordRequired) ->
          passwordRequired.should.equal "Informe sua senha."
          done()

  describe 'Can login successfully with regular user', ->
    before (done) ->
      page.clearCookies =>
        page.visit ->
          page.setFieldsAs userA
          page.clickLoginButton done
    it 'does not show the login failed message', (done) ->
      page.hasErrors (itHas) ->
        itHas.should.be.false
        done()
    it 'is at the home page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/"
        done()
    it 'does not show login link', (done) ->
      page.loginLinkExists (itDoes) ->
        itDoes.should.be.false
        done()
    it 'shows logout link', (done) ->
      page.logoutLinkExists (itDoes) ->
        itDoes.should.be.true
        done()
    it 'does not show admin link', (done) ->
      page.adminLinkExists (itDoes) ->
        itDoes.should.be.false
        done()
    it 'shows user name', (done) ->
      page.userGreeting (userGreeting) ->
        userGreeting.should.equal userA.name
        done()

  describe 'Trying to access admin page redirects to login with redirectTo query string set', ->
    before (done) ->
      page.clearCookies =>
        page.visit "http://localhost:8000/admin", done
    it 'is at the login page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/account/login?redirectTo=/admin/"
        done()

  describe 'Login with admin user redirects to original url', ->
    before (done) ->
      page.clearCookies =>
        page.visit "http://localhost:8000/admin", ->
          page.setFieldsAs userSellerC
          page.clickLoginButton done
    it 'is at the admin page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/admin/"
        done()

  describe 'Three errors on login does not show captcha if user does not exist', ->
    it 'does not show login link', (done) ->
      page.clearCookies =>
        page.visit ->
          page.setFieldsAs email:"someinexistentuser@a.com", password:"abcdasklfadsj"
          page.clickLoginButton ->
            page.setFieldsAs email:"someinexistentuser@a.com", password:"abcdasklfadsj"
            page.clickLoginButton ->
              page.setFieldsAs email:"someinexistentuser@a.com", password:"abcdasklfadsj"
              page.clickLoginButton ->
                page.showsCaptcha (itShows) ->
                  itShows.should.be.false
                  done()

  describe 'Three errors on login shows captcha if user exists', ->
    it 'shows login link', (done) ->
      page.clearCookies =>
        page.visit ->
          page.setFieldsAs email:userA.email, password:"abcdasklfadsj"
          page.clickLoginButton ->
            page.setFieldsAs email:userA.email, password:"abcdasklfadsj"
            page.clickLoginButton ->
              page.setFieldsAs email:userA.email, password:"abcdasklfadsj"
              page.clickLoginButton ->
                page.showsCaptcha (itShows) ->
                  itShows.should.be.true
                  done()
