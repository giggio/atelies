Store     = require '../../models/store'
Product   = require '../../models/product'

describe 'store home page', ->
  browser = null
  store = null
  afterAll -> browser.destroy() if browser?
  describe 'when store doesnt exist', (done) ->
    beforeAll (done) ->
      browser = newBrowser browser
      cleanDB (error) ->
        if error
          return done error
        whenServerLoaded ->
          browser.visit "http://localhost:8000/store_1", (error, browser, status) ->
            if error and status isnt 404
              console.error "Error visiting. " + error.stack
              done error
            else
              done()
    it 'should display not found', ->
      expect(browser.text(".page-header")).toBe 'Loja não existe'
    it 'should return a not found status code', ->
      expect(browser.statusCode).toBe 404
    
  describe 'when store exists and has no products', (done) ->
    beforeAll (done) ->
      browser = newBrowser browser
      cleanDB (error) ->
        return done error if error
        store = generator.store.a()
        store.save()
        whenServerLoaded ->
          browser.visit "http://localhost:8000/store_1", done
    it 'should display no products', ->
      expect(browser.query('#products tbody').children.length).toBe 0

  describe 'when store exists and has products', (done) ->
    beforeAll (done) ->
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
          browser.visit "http://localhost:8000/store_1", done
    it 'should display the products', ->
      expect(browser.query('#products tbody').children.length).toBe 2
