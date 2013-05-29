require './support/_specHelper'
Store     = require '../../app/models/store'
Product   = require '../../app/models/product'

describe 'store home page', ->
  browser = null
  store = null
  after -> browser.destroy() if browser?
  describe 'when store doesnt exist', (done) ->
    before (done) ->
      browser = newBrowser browser
      cleanDB (error) ->
        return done error if error
        whenServerLoaded ->
          browser.storeHomePage.visit "store_1", silent:on, (error) ->
            if error and browser.statusCode isnt 404
              console.error "Error visiting. " + error.stack
              done error
            else
              done()
    it 'should display not found', ->
      expect(browser.text("#notExistent")).to.equal 'Loja não existe'
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
      browser.storeHomePage.products().length.should.equal 0

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
      browser.storeHomePage.products().length.should.equal 2
