Store     = require '../../models/store'
Product   = require '../../models/product'
zombie    = new require 'zombie'

describe 'store home page', ->
  browser = null
  store = null
  describe 'when store doesnt exist', (done) ->
    beforeAll (done) ->
      browser = new zombie.Browser()
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
      browser = new zombie.Browser()
      cleanDB (error) ->
        if error
          return done error
        store = generator.store.a()
        store.save()
        whenServerLoaded ->
          browser.visit "http://localhost:8000/store_1", (error) ->
            if error
              console.error "Error visiting. " + error.stack
              done error
            else
              done()
    it 'should display no products', ->
      expect(browser.query('#products tbody').children.length).toBe 0

  describe 'when store exists and has products', (done) ->
    beforeAll (done) ->
      browser = new zombie.Browser()
      cleanDB (error) ->
        if error
          return done error
        store = new Store name: 'store 1', slug: 'store_1'
        store.save()
        product1 = new Product(name: 'name 1', slug: 'name_1', picture: 'http://lorempixel.com/150/150/cats', price: 11.1, storeName: 'store 1', storeSlug: 'store_1')
        product2 = new Product(name: 'name 2', slug: 'name_2', picture: 'http://lorempixel.com/150/150/cats', price: 12.2, storeName: 'store 1', storeSlug: 'store_1')
        product1.save()
        product2.save()
        whenServerLoaded ->
          browser.visit "http://localhost:8000/store_1", (error) ->
            if error
              console.error "Error visiting. " + error.stack
              done error
            else
              done()
    it 'should display the products', ->
      expect(browser.query('#products tbody').children.length).toBe 2
