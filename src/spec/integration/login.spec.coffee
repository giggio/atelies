describe 'Login', ->
  userA = userB = userSellerC = browser = page = null
  beforeAll (done) ->
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
  afterAll -> browser.destroy()

  describe 'Login in with unknown user fails', ->
    beforeAll (done) ->
      page.visit (error) ->
        return done error if error
        page.setFieldsAs email:"someinexistentuser@a.com", password:"abcdasklfadsj"
        page.clickLoginButton done
    it 'shows login link', ->
      expect(page.loginLinkExists()).toBeTruthy()
    it 'does not show logout link', ->
      expect(page.logoutLinkExists()).toBeFalsy()
    it 'shows the login failed message', ->
      expect(page.errors()).toBe 'Login falhou'
    it 'is at the login page', ->
      expect(browser.location.toString()).toBe "http://localhost:8000/login"
    it 'does not show admin link', ->
      expect(page.adminLinkExists()).toBeFalsy()

  describe 'Must supply name and password or form is not submitted', ->
    beforeAll (done) ->
      page.visit (error) ->
        return done error if error
        page.clickLoginButton done
    it 'does not show the login failed message', ->
      expect(page.errors()).toBe ''
    it 'is at the login page', ->
      expect(browser.location.toString()).toBe "http://localhost:8000/login"
    it 'Required messages are shown', ->
      expect(page.emailRequired()).toBe "Informe seu e-mail."
      expect(page.passwordRequired()).toBe "Informe sua senha."

  describe 'Can login successfully with regular user', ->
    beforeAll (done) ->
      page.visit (error) ->
        return done error if error
        page.setFieldsAs userA
        page.clickLoginButton done
    it 'does not show the login failed message', ->
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
      expect(page.userGreeting()).toBe userA.name
