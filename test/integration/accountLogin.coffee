require './support/_specHelper'
Page    = require './support/pages/accountLoginPage'
Q       = require 'q'

describe 'Login', ->
  userA = userB = userSellerC = page = null
  before ->
    page = new Page()
    cleanDB().then ->
      userA = generator.user.a()
      userA.save()
      userB = generator.user.b()
      userB.save()
      userSellerC = generator.user.c()
      userSellerC.save()
    .then whenServerLoaded

  describe 'Login in with unknown user fails', ->
    before ->
      page.visit()
      .then -> page.setFieldsAs email:"someinexistentuser@a.com", password:"abcdasklfadsj"
      .then page.clickLoginButton
    it 'does not show logout link', test -> page.logoutLinkExists().should.eventually.be.false
    it 'shows the login failed message', test -> page.errors().should.become 'Login falhou'
    it 'is at the login page', test -> page.currentUrl().should.become "http://localhost:8000/account/login"
    it 'does not show admin link', test -> page.adminLinkExists().should.eventually.be.false

  describe 'Must supply name and password or form is not submitted', ->
    before ->
      page.visit()
      .then page.clickLoginButton
    it 'does not show the login failed message', test -> page.hasErrors().should.eventually.be.false
    it 'is at the login page', test -> page.currentUrl().should.become "http://localhost:8000/account/login"
    it 'Required messages are shown', test ->
      Q.all [
        page.emailRequired().should.become "Informe seu e-mail."
        page.passwordRequired().should.become "Informe sua senha."
      ]

  describe 'Can login successfully with regular user', ->
    before ->
      page.clearCookies()
      .then page.visit
      .then -> page.setFieldsAs userA
      .then page.clickLoginButton
    it 'does not show the login failed message', test -> page.hasErrors().should.eventually.be.false
    it 'is at the home page', test -> page.currentUrl().should.become "http://localhost:8000/"
    it 'does not show login link', test -> page.loginLinkExists().should.eventually.be.false
    it 'shows logout link', test -> page.logoutLinkExists().should.eventually.be.true
    it 'does not show admin link', test -> page.adminLinkExists().should.eventually.be.false
    it 'shows user name', test -> page.userGreeting().should.become userA.name

  describe 'Trying to access admin page redirects to login with redirectTo query string set', ->
    before ->
      page.clearCookies()
      .then -> page.visit "http://localhost:8000/admin"
    it 'is at the login page', test -> page.currentUrl().should.become "http://localhost:8000/account/login?redirectTo=/admin/"

  describe 'Login with admin user redirects to original url', ->
    before ->
      page.clearCookies()
      .then -> page.visit "http://localhost:8000/admin"
      .then -> page.setFieldsAs userSellerC
      .then page.clickLoginButton
    it 'is at the admin page', test -> page.currentUrl().should.become "http://localhost:8000/admin/"

  describe 'Three errors on login does not show captcha if user does not exist', ->
    it 'does not show login link', test ->
      page.clearCookies()
      .then page.visit
      .then -> page.setFieldsAs email:"someinexistentuser@a.com", password:"abcdasklfadsj"
      .then page.clickLoginButton
      .then -> page.setFieldsAs email:"someinexistentuser@a.com", password:"abcdasklfadsj"
      .then page.clickLoginButton
      .then -> page.setFieldsAs email:"someinexistentuser@a.com", password:"abcdasklfadsj"
      .then page.clickLoginButton
      .then page.showsCaptcha().should.eventually.be.false

  describe 'Three errors on login shows captcha if user exists', ->
    it 'shows login link', test ->
      page.clearCookies()
      .then page.visit
      .then -> page.setFieldsAs email:userA.email, password:"abcdasklfadsj"
      .then page.clickLoginButton
      .then -> page.setFieldsAs email:userA.email, password:"abcdasklfadsj"
      .then page.clickLoginButton
      .then -> page.setFieldsAs email:userA.email, password:"abcdasklfadsj"
      .then page.clickLoginButton
      .then page.showsCaptcha().should.eventually.be.true
