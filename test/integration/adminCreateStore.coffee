require './support/_specHelper'
Store     = require '../../app/models/store'
User      = require '../../app/models/user'

describe 'Admin create store page', ->
  exampleStore = userSeller = browser = null
  before (done) -> whenServerLoaded done
  after -> browser.destroy() if browser?
  describe 'creates a store', (done) ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        userSeller = generator.user.c()
        userSeller.save()
        exampleStore = generator.store.a()
        browser = newBrowser browser
        browser.loginPage.navigateAndLoginWith userSeller, ->
          browser.adminCreateStorePage.visit (error) ->
            return done error if error
            browser.adminCreateStorePage.setFieldsAs exampleStore
            browser.adminCreateStorePage.clickCreateStoreButton done
    it 'is at the admin store page', ->
      expect(browser.location.toString()).to.equal "http://localhost:8000/admin#store/#{exampleStore.slug}"
    it 'shows store created message', ->
      expect(browser.text('#message')).to.equal "Loja criada com sucesso"
    it 'created a new store with correct information', (done) ->
      Store.findBySlug exampleStore.slug, (error, store) ->
        return done error if error
        expect(store).not.to.be.null
        expect(store.slug).to.equal exampleStore.slug
        expect(store.name).to.equal exampleStore.name
        expect(store.email).to.equal exampleStore.email
        expect(store.description).to.equal exampleStore.description
        expect(store.homePageDescription).to.equal exampleStore.homePageDescription
        expect(store.homePageImage).to.equal exampleStore.homePageImage
        expect(store.urlFacebook).to.equal exampleStore.urlFacebook
        expect(store.urlTwitter).to.equal exampleStore.urlTwitter
        expect(store.phoneNumber).to.equal exampleStore.phoneNumber
        expect(store.city).to.equal exampleStore.city
        expect(store.state).to.equal exampleStore.state
        expect(store.otherUrl).to.equal exampleStore.otherUrl
        expect(store.banner).to.equal exampleStore.banner
        expect(store.flyer).to.equal exampleStore.flyer
        done()
    it 'added the store to the user', (done) ->
      User.findById userSeller.id, (err, user) ->
        return done err if err
        user.stores.length.should.equal 1
        done()

  describe 'does not create a store (missing or wrong info)', (done) ->
    page = null
    before (done) ->
      cleanDB (error) ->
        return done error if error
        userSeller = generator.user.c()
        userSeller.save()
        browser = newBrowser browser
        exampleStore = generator.store.empty()
        browser.loginPage.navigateAndLoginWith userSeller, ->
          page = browser.adminCreateStorePage
          page.visit (error) ->
            return done error if error
            exampleStore.banner = "abc"
            exampleStore.email = "bla"
            exampleStore.flyer = "mng"
            exampleStore.otherUrl = "def"
            page.setFieldsAs exampleStore
            page.clickCreateStoreButton done
    it 'is at the store create page', ->
      expect(browser.location.toString()).to.equal "http://localhost:8000/admin#createStore"
    it 'does not show store created message', ->
      expect(browser.query('#message')).to.be.null
    it 'shows validation messages', ->
      page.errorMessageFor('name').should.equal "Informe o nome da loja."
      page.errorMessageFor('email').should.equal "O e-mail deve ser válido."
      page.errorMessageFor('city').should.equal "Informe a cidade."
      page.errorMessageFor('banner').should.equal "Informe um link válido para o banner, começando com http ou https."
      page.errorMessageFor('flyer').should.equal "Informe um link válido para o flyer, começando com http ou https."
      page.errorMessageFor('otherUrl').should.equal "Informe um link válido para o outro site, começando com http ou https."
    it 'did not create a store with missing info', (done) ->
      Store.find (error, stores) ->
        return done error if error
        expect(stores.length).to.equal 0
        done()
