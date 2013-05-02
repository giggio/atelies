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
    xit 'mostra mensagem de loja criada com sucesso', ->
      expect(browser.text('#message')).toBe "Loja criado com sucesso"
