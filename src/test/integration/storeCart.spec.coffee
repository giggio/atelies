require './support/_specHelper'
Store     = require '../../models/store'
Product   = require '../../models/product'

describe 'Store shopping cart page', ->
  store = product1 = product2 = store2 = product3 = browser = null
  #after -> browser.destroy() if browser?
  before (done) =>
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
    before (done) =>
      browser = newBrowser browser
      whenServerLoaded ->
        browser.storeCartPage.visit "store_1", (error) -> doneError error, done
    it 'does not show the cart items table', ->
      expect(browser.query('#cartItems')).to.be.null
  describe 'when add one item to cart', ->
    it 'when add one item to cart it is at the cart location and shows product info', (done) ->
      browser = newBrowser()
      whenServerLoaded ->
        browser.storeProductPage.visit 'store_1', 'name_1', (error) ->
          return done error if error
          browser.storeProductPage.purchaseItem ->
            expect(browser.location.toString()).to.equal "http://localhost:8000/store_1#cart"
            browser.reload ->
              expect(browser.storeCartPage.itemsQuantity()).to.equal 1
              expect(browser.storeCartPage.id()).to.equal product1._id.toString()
              expect(browser.storeCartPage.name()).to.equal product1.name
              expect(browser.storeCartPage.quantity()).to.equal 1
              done()

  describe 'when add two items to cart', ->
    before (done) ->
      browser = newBrowser()
      whenServerLoaded ->
        browser.storeProductPage.visit 'store_1', 'name_1', (error) ->
          return done error if error
          browser.storeProductPage.purchaseItem ->
            browser.storeProductPage.visit 'store_1', 'name_1', (error) ->
              return done error if error
              browser.storeProductPage.purchaseItem ->
                #it 'is at the cart location', ->
                expect(browser.location.toString()).to.equal "http://localhost:8000/store_1#cart"
                browser.reload done
    it 'shows a cart with one item', ->
      expect(browser.storeCartPage.itemsQuantity()).to.equal 1
    it 'shows quantity of two', ->
      expect(browser.storeCartPage.quantity()).to.equal 2
  
  describe 'when working with a cart with products from different stores', ->
    before (done) =>
      @timeout 3000
      browser = newBrowser()
      whenServerLoaded ->
        browser.on 'error', done
        browser.storeProductPage.visit 'store_1', 'name_1', (error) ->
          return done error if error
          browser.storeProductPage.purchaseItem ->
            browser = newBrowser browser
            browser.storeProductPage.visit 'store_2', 'name_3', (error) ->
              return done error if error
              browser.storeProductPage.purchaseItem done
    it 'on the 1st store it shows only the first store products', (done) ->
      @timeout 30000
      browser = newBrowser browser
      browser.storeCartPage.visit "store_1", (error) ->
        return done error if error
        expect(browser.storeCartPage.itemsQuantity()).to.equal 1
        expect(browser.storeCartPage.id()).to.equal product1._id.toString()
        expect(browser.storeCartPage.name()).to.equal product1.name
        expect(browser.storeCartPage.quantity()).to.equal 1
        done()
    it 'on the 2st store it shows only the second store products', (done) ->
      @timeout 30000
      browser = newBrowser browser
      browser.storeCartPage.visit "store_2", (error) ->
        return done error if error
        expect(browser.storeCartPage.itemsQuantity()).to.equal 1
        expect(browser.storeCartPage.id()).to.equal product3._id.toString()
        expect(browser.storeCartPage.name()).to.equal product3.name
        expect(browser.storeCartPage.quantity()).to.equal 1
        done()
