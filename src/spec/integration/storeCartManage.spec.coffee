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
        browser.storeProductPage.visit 'store_1', 'name_1', (error) ->
          return done error if error
          browser.storeProductPage.purchaseItem ->
            return done error if error
            browser.storeProductPage.visit 'store_1', 'name_2', (error) ->
              return done error if error
              browser.storeProductPage.purchaseItem ->
                return done error if error
                browser.storeCartPage.removeItem product1, done
    it 'is at the cart location', ->
      expect(browser.location.toString()).toBe "http://localhost:8000/store_1#cart"
    it 'shows a cart with one item', ->
      expect(browser.storeCartPage.itemsQuantity()).toBe 1
    it 'shows item id', ->
      expect(browser.storeCartPage.id()).toBe product2._id.toString()
  describe 'can set quantity', ->
    beforeAll (done) =>
      browser = newBrowser()
      whenServerLoaded ->
        browser.storeProductPage.visit 'store_1', 'name_1', (error) ->
          return done error if error
          browser.storeProductPage.purchaseItem ->
            return done error if error
            browser.storeCartPage.updateQuantity product1, 3, (error) ->
              return done error if error
              browser = newBrowser browser
              browser.storeCartPage.visit 'store_1', done
    it 'is at the cart location', ->
      expect(browser.location.toString()).toBe "http://localhost:8000/store_1#cart"
    it 'shows a cart with one item', ->
      expect(browser.storeCartPage.itemsQuantity()).toBe 1
    it 'shows quantity of two', ->
      expect(browser.storeCartPage.quantity()).toBe 3
  describe 'when setting quantity to incorrect value a validation error appears', ->
    beforeAll (done) =>
      browser = newBrowser()
      whenServerLoaded ->
        browser.storeProductPage.visit 'store_1', 'name_1', (error) ->
          return done error if error
          browser.storeProductPage.purchaseItem ->
            return done error if error
            browser.storeCartPage.updateQuantity product1, 'abc', done
    it 'shows error message', ->
      expect(browser.text("label[for='quantity#{product1._id}']")).toBe "Apenas números permitidos."
    it 'shows original quantity', (done) ->
      browser = newBrowser browser
      browser.storeCartPage.visit 'store_1', (error) ->
        return done error if error
        expect(browser.storeCartPage.quantity()).toBe 1
        done()
  describe 'clearing cart', ->
    beforeAll (done) =>
      browser = newBrowser()
      whenServerLoaded ->
        browser.storeProductPage.visit 'store_1', 'name_1', (error) ->
          return done error if error
          browser.storeProductPage.purchaseItem ->
            return done error if error
            browser.storeCartPage.clearCart done
    it 'shows an empty cart', ->
      expect(browser.storeCartPage.itemsQuantity()).toBe 0
