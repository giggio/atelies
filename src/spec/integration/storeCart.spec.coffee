Store     = require '../../models/store'
Product   = require '../../models/product'
zombie    = new require 'zombie'

describe 'Store shopping cart page', ->
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
  describe 'when add one item to cart', ->
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
          browser.visit "http://localhost:8000/store_1#name_1", (error) ->
            return done error if error
            browser.pressButton '#purchaseItem', done
    it 'is at the cart location', ->
      expect(browser.location.toString()).toBe "http://localhost:8000/store_1#cart"
    it 'shows a cart with one item', ->
      expect(browser.query('#cartItems tbody').children.length).toBe 1
    it 'shows product id', ->
      expect(browser.text('#cartItems > tbody > tr > td:first-child')).toBe product1._id.toString()
    it 'shows product name', ->
      expect(browser.text('#cartItems > tbody > tr > td:nth-child(2)')).toBe product1.name
    it 'shows quantity of one', ->
      expect(browser.text('#cartItems > tbody > tr > td:nth-child(3)')).toBe '1'
  describe 'when add two items to cart', ->
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
          browser.visit "http://localhost:8000/store_1#name_1", (error) ->
            return done error if error
            browser.pressButton '#purchaseItem', done
            browser.visit "http://localhost:8000/store_1#name_1", (error) ->
              return done error if error
              browser.pressButton '#purchaseItem', done
    it 'is at the cart location', ->
      expect(browser.location.toString()).toBe "http://localhost:8000/store_1#cart"
    it 'shows a cart with one item', ->
      expect(browser.query('#cartItems tbody').children.length).toBe 1
    it 'shows quantity of two', ->
      expect(browser.text('#cartItems > tbody > tr > td:nth-child(3)')).toBe '2'
