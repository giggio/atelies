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
      store2 = generator.store.b()
      store2.save()
      product3 = generator.product.c()
      product3.save()
      done()
  describe 'show empty cart', ->
    beforeAll (done) =>
      browser = new zombie.Browser()
      whenServerLoaded ->
        browser.visit "http://localhost:8000/store_1#cart", (error) -> doneError error, done
    it 'should show an empty cart table', ->
      expect(browser.query('#cartItems tbody').children.length).toBe 0
  describe 'when add one item to cart', ->
    beforeAll (done) =>
      browser = new zombie.Browser()
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
      expect(browser.query('#cartItems > tbody > tr > td:nth-child(3) .quantity').value).toBe '1'
  describe 'when add two items to cart', ->
    beforeAll (done) =>
      browser = new zombie.Browser()
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
      expect(browser.query('#cartItems > tbody > tr > td:nth-child(3) .quantity').value).toBe '2'
  
  describe 'when working with a cart with products from different stores', ->
    beforeAll (done) =>
      browser = newBrowser()
      whenServerLoaded ->
        browser.on 'error', done
        browser.visit "http://localhost:8000/store_1#name_1", (error) ->
          return done error if error
          browser.pressButtonWait "#product#{product1._id} > #purchaseItem", ->
            browser = newBrowser browser
            browser.visit "http://localhost:8000/store_2#name_3", (error) ->
              return done error if error
              browser.pressButtonWait "#product#{product3._id} > #purchaseItem", done
    it 'on the 1st store it shows only the first store products', (done) ->
      browser = newBrowser browser
      browser.visit "http://localhost:8000/store_1#cart", (error) ->
        return done error if error
        expect(browser.query('#cartItems > tbody').children.length).toBe 1
        expect(browser.text('#cartItems > tbody > tr > td:first-child')).toBe product1._id.toString()
        expect(browser.text('#cartItems > tbody > tr > td:nth-child(2)')).toBe product1.name
        expect(browser.query('#cartItems > tbody > tr > td:nth-child(3) .quantity').value).toBe '1'
        done()
    it 'on the 2st store it shows only the second store products', (done) ->
      browser = newBrowser browser
      browser.visit "http://localhost:8000/store_2#cart", (error) ->
        return done error if error
        expect(browser.query('#cartItems > tbody').children.length).toBe 1
        expect(browser.text('#cartItems > tbody > tr > td:first-child')).toBe product3._id.toString()
        expect(browser.text('#cartItems > tbody > tr > td:nth-child(2)')).toBe product3.name
        expect(browser.query('#cartItems > tbody > tr > td:nth-child(3) .quantity').value).toBe '1'
        done()
