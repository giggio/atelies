require './support/_specHelper'

describe 'Admin home page', ->
  userSeller = userNonSeller = store1 = store2 = null
  before (done) ->
    cleanDB (error) ->
      return done error if error
      store1 = generator.store.a()
      store1.save()
      store2 = generator.store.b()
      store2.save()
      store3 = generator.store.c()
      store3.save()
      userNonSeller = generator.user.a()
      userNonSeller.save()
      userSeller = generator.user.c()
      userSeller.stores.push store1
      userSeller.stores.push store2
      userSeller.save()
      whenServerLoaded done

  describe 'accessing with a logged in and seller user', ->
    browser = page = null
    before (done) ->
      browser = newBrowser()
      page = browser.adminHomePage
      browser.loginPage.navigateAndLoginWith userSeller, ->
        page.visit done
    after -> browser.destroy()
    it 'allows to create a new store', ->
      expect(page.createStoreText()).to.equal 'Crie uma nova loja'
    it 'shows existing user stores to manage', ->
      expect(page.storesQuantity()).to.equal 2
    it 'links to store manage pages', ->
      stores = page.stores()
      expect(stores[0].url).to.equal "#store/#{store1.slug}"
      expect(stores[1].url).to.equal "#store/#{store2.slug}"

  describe 'accessing with a logged in but not a seller user', ->
    browser = page = null
    before (done) ->
      browser = newBrowser()
      page = browser.adminHomePage
      loginPage = browser.loginPage
      loginPage.visit ->
        loginPage.loginWith userNonSeller, ->
          page.visit done
    after -> browser.destroy()
    it 'redirects user to login', ->
      expect(browser.location.toString()).to.equal "http://localhost:8000/notseller"

  describe 'accessing with an anonymous user', ->
    browser = page = null
    before (done) ->
      browser = newBrowser()
      page = browser.adminHomePage
      page.visit done
    after -> browser.destroy()
    it 'redirects user to login', ->
      expect(browser.location.toString()).to.equal "http://localhost:8000/account/login?redirectTo=/admin"
