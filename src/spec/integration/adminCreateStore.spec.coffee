zombie    = new require 'zombie'
Store     = require '../../models/store'

describe 'Admin home page', ->
  describe 'Creating a store', ->
    browser = null
    exampleStore = generator.store.a()
    beforeAll (done) ->
      browser = newBrowser()
      cleanDB (error) ->
        return done error if error
        whenServerLoaded ->
          browser.adminCreateStorePage.visit (error) ->
            return done error if error
            browser.adminCreateStorePage.setFieldsAs exampleStore
            browser.adminCreateStorePage.clickCreateStoreButton done
    it 'created a new store with correct information', (done) ->
      Store.findBySlug exampleStore.slug, (error, store) ->
        return done error if error
        expect(store).not.toBeNull()
        expect(store.slug).toBe exampleStore.slug
        expect(store.name).toBe exampleStore.name
        expect(store.phoneNumber).toBe exampleStore.phoneNumber
        expect(store.city).toBe exampleStore.city
        expect(store.state).toBe exampleStore.state
        expect(store.otherUrl).toBe exampleStore.otherUrl
        expect(store.banner).toBe exampleStore.banner
        done()
    it 'is at the admin store page', ->
      expect(browser.location.toString()).toBe "http://localhost:8000/admin#manageStore/#{exampleStore.slug}"
    it 'shows store created message', ->
      expect(browser.text('#message')).toBe "Loja criada com sucesso"
  describe 'Not creating a store (missing or wrong info)', ->
    browser = null
    exampleStore = generator.store.empty()
    beforeAll (done) ->
      browser = newBrowser()
      cleanDB (error) ->
        return done error if error
        whenServerLoaded ->
          browser.adminCreateStorePage.visit (error) ->
            return done error if error
            exampleStore.banner = "abc"
            exampleStore.otherUrl = "def"
            browser.adminCreateStorePage.setFieldsAs exampleStore
            browser.adminCreateStorePage.clickCreateStoreButton done
    it 'did not create a store with missing info', (done) ->
      Store.find (error, stores) ->
        return done error if error
        expect(stores.length).toBe 0
        done()
    it 'is at the store create page', ->
      expect(browser.location.toString()).toBe "http://localhost:8000/admin#createStore"
    it 'does not show store created message', ->
      expect(browser.query('#message')).toBeUndefined()
    it 'shows validation messages', ->
      expect(browser.text("label[for='name']")).toBe "Informe o nome da loja."
      expect(browser.text("label[for='city']")).toBe "Informe a cidade."
      expect(browser.text("label[for='banner']")).toBe "Informe um link válido para o banner, começando com http ou https."
      expect(browser.text("label[for='otherUrl']")).toBe "Informe um link válido para o outro site, começando com http ou https."
