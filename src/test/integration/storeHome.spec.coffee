require './support/_specHelper'
Store     = require '../../models/store'
Product   = require '../../models/product'

describe 'store home page', ->
  browser = null
  store = null
  after -> browser.destroy() if browser?
  describe 'when store doesnt exist', (done) ->
    before (done) ->
      browser = newBrowser browser
      cleanDB (error) ->
        if error
          return done error
        whenServerLoaded ->
          browser.storeHomePage.visit "store_1", (error, browser, status) ->
            if error and status isnt 404
              console.error "Error visiting. " + error.stack
              done error
            else
              done()
    it 'should display not found', ->
      expect(browser.text(".page-header")).to.equal 'Loja não existe'
    it 'should return a not found status code', ->
      expect(browser.statusCode).to.equal 404
    
  describe 'when store exists and has no products', (done) ->
    before (done) ->
      browser = newBrowser browser
      cleanDB (error) ->
        return done error if error
        store = generator.store.a()
        store.save()
        whenServerLoaded ->
          browser.storeHomePage.visit "store_1", done
    it 'should display no products', ->
      expect(browser.query('#products tbody').children.length).to.equal 0

  describe 'when store exists and has products', (done) ->
    before (done) ->
      browser = newBrowser browser
      cleanDB (error) ->
        return done error if error
        store = generator.store.a()
        store.save()
        product1 = generator.product.a()
        product2 = generator.product.b()
        product1.save()
        product2.save()
        whenServerLoaded ->
          browser.storeHomePage.visit "store_1", done
    it 'should display the products', ->
      expect(browser.query('#products tbody').children.length).to.equal 2
