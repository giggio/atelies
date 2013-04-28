Store     = require '../../models/store'
Product   = require '../../models/product'
zombie    = new require 'zombie'

describe 'Store shopping cart page', ->
  store = product1 = product2 = store2 = product3 = browser = null
  beforeAll (done) =>
    cleanDB (error) ->
      return done error if error
      store = generator.store.a()
      store.save()
      product1 = generator.product.a()
      product1.save()
      product2 = generator.product.b()
      product2.save()
      done()
  describe 'with two items, when remove on item', ->
    beforeAll (done) =>
      browser = newBrowser()
      whenServerLoaded ->
        browser.visit "http://localhost:8000/store_1#name_1", (error) ->
          return done error if error
          browser.pressButtonWait '#purchaseItem', ->
            return done error if error
            browser.visit "http://localhost:8000/store_1#name_2", (error) ->
              return done error if error
              browser.pressButtonWait '#purchaseItem', (error) ->
                return done error if error
                browser.pressButtonWait "#product#{product1._id} .remove", done
    it 'is at the cart location', ->
      expect(browser.location.toString()).toBe "http://localhost:8000/store_1#cart"
    it 'shows a cart with one item', ->
      expect(browser.query('#cartItems tbody').children.length).toBe 1
    it 'shows quantity of two', ->
      expect(browser.text('#cartItems > tbody > tr > td:first-child')).toBe product2._id.toString()
  describe 'can set quantity', ->
    beforeAll (done) =>
      browser = newBrowser()
      whenServerLoaded ->
        browser.visit "http://localhost:8000/store_1#name_1", (error) ->
          return done error if error
          browser.pressButtonWait '#purchaseItem', ->
            return done error if error
            browser.fill("#product#{product1._id} .quantity", '3').pressButton ".updateQuantity", (error) ->
              return done error if error
              browser = newBrowser browser
              browser.visit "http://localhost:8000/store_1#cart", done
    it 'is at the cart location', ->
      expect(browser.location.toString()).toBe "http://localhost:8000/store_1#cart"
    it 'shows a cart with one item', ->
      expect(browser.query('#cartItems tbody').children.length).toBe 1
    it 'shows quantity of two', ->
      expect(browser.query("#product#{product1._id} .quantity").value).toBe '3'
