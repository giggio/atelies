Store     = require '../../models/store'
Product   = require '../../models/product'
zombie    = new require 'zombie'

describe 'Store shoppint cart page', ->
  describe 'show empty cart', ->
    eachCalled = false
    store = browser = null
    beforeEach (done) ->
      return done() if eachCalled
      eachCalled = true
      browser = new zombie.Browser()
      cleanDB (error) ->
        return done error if error
        store = generator.store.a()
        store.save()
        whenServerLoaded ->
          browser.visit "http://localhost:8000/store_1#cart", (error) -> doneError error, done
    it 'should show an empty cart table', ->
      expect(browser.query('#cartItems tbody').children.length).toBe 0
  xdescribe 'add one item to cart', ->
    eachCalled = false
    store = product1 = product2 = browser = null
    beforeEach (done) ->
      return done() if eachCalled
      eachCalled = true
      browser = new zombie.Browser()
      cleanDB (error) ->
        return done error if error
        store = generator.store.a()
        store.save()
        product1 = generator.product.a()
        product1.save()
        product2 = generator.product.b()
        product2.save()
        whenServerLoaded ->
          browser.visit "http://localhost:8000/store_1#cart", (error) -> doneError error, done
