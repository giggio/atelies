describe 'Admin home page', ->
  userSeller = userNonSeller = store1 = store2 = null
  beforeAll (done) ->
    cleanDB (error) ->
      return done error if error
      store1 = generator.store.a()
      store1.save()
      store2 = generator.store.b()
      store2.save()
      userNonSeller = generator.user.a()
      userNonSeller.save()
      userSeller = generator.user.c()
      userSeller.save()
      whenServerLoaded done
  describe 'accessing with a logged in and seller user', ->
    browser = page = null
    beforeAll (done) ->
      browser = newBrowser()
      page = browser.adminHomePage
      loginPage = browser.loginPage
      loginPage.visit ->
        loginPage.loginWith userSeller, ->
          page.visit done
    afterAll -> browser.destroy()
    it 'allows to create a new store', ->
      expect(page.createStoreText()).toBe 'Crie uma nova loja'
    it 'shows existing stores to manage', ->
      expect(page.storesQuantity()).toBe 2
    it 'links to store manage pages', ->
      stores = page.stores()
      expect(stores[0].url).toBe "#manageStore/#{store1.slug}"
      expect(stores[1].url).toBe "#manageStore/#{store2.slug}"

  describe 'accessing with an anonymous user', ->
    browser = page = null
    beforeAll (done) ->
      browser = newBrowser()
      page = browser.adminHomePage
      page.visit done
    afterAll -> browser.destroy()
    it 'redirects user to login', ->
      expect(browser.location.toString()).toBe "http://localhost:8000/login"
