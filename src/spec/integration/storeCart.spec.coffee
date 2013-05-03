Store     = require '../../models/store'
Product   = require '../../models/product'

describe 'Store shopping cart page', ->
  store = product1 = product2 = store2 = product3 = browser = null
  afterEach -> browser.destroy() if browser?
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
      browser = newBrowser browser
      whenServerLoaded ->
        browser.storeCartPage.visit "store_1", (error) -> doneError error, done
    it 'does not show the cart items table', ->
      expect(browser.query('#cartItems')).toBeNull()
  describe 'when add one item to cart', ->
    it 'when add one item to cart it is at the cart location and shows product info', ((done) ->
      browser = newBrowser()
      whenServerLoaded ->
        browser.storeProductPage.visit 'store_1', 'name_1', (error) ->
          return done error if error
          browser.storeProductPage.purchaseItem ->
            expect(browser.location.toString()).toBe "http://localhost:8000/store_1#cart"
            browser.reload ->
              expect(browser.storeCartPage.itemsQuantity()).toBe 1
              expect(browser.storeCartPage.id()).toBe product1._id.toString()
              expect(browser.storeCartPage.name()).toBe product1.name
              expect(browser.storeCartPage.quantity()).toBe 1
              done()
    ), 20000
  describe 'when add two items to cart', ->
    it 'adds two items to cart', ((done) ->
      browser = newBrowser()
      whenServerLoaded ->
        browser.storeProductPage.visit 'store_1', 'name_1', (error) ->
          return done error if error
          browser.storeProductPage.purchaseItem ->
            browser.storeProductPage.visit 'store_1', 'name_1', (error) ->
              return done error if error
              browser.storeProductPage.purchaseItem ->
                #it 'is at the cart location', ->
                expect(browser.location.toString()).toBe "http://localhost:8000/store_1#cart"
                browser.reload ->
                  #it 'shows a cart with one item', ->
                  expect(browser.storeCartPage.itemsQuantity()).toBe 1
                  #it 'shows quantity of two', ->
                  expect(browser.storeCartPage.quantity()).toBe 2
                  done()
     ), 40000
  
  describe 'when working with a cart with products from different stores', ->
    it 'works with different stores', ((done) =>
      browser = newBrowser()
      whenServerLoaded ->
        browser.on 'error', done
        browser.storeProductPage.visit 'store_1', 'name_1', (error) ->
          return done error if error
          browser.storeProductPage.purchaseItem ->
            browser = newBrowser browser
            browser.storeProductPage.visit 'store_2', 'name_3', (error) ->
              return done error if error
              browser.storeProductPage.purchaseItem ->
                #it 'on the 1st store it shows only the first store products', (done) ->
                browser = newBrowser browser
                browser.storeCartPage.visit "store_1", (error) ->
                  return done error if error
                  expect(browser.storeCartPage.itemsQuantity()).toBe 1
                  expect(browser.storeCartPage.id()).toBe product1._id.toString()
                  expect(browser.storeCartPage.name()).toBe product1.name
                  expect(browser.storeCartPage.quantity()).toBe 1
                  #it 'on the 2st store it shows only the second store products', (done) ->
                  browser = newBrowser browser
                  browser.storeCartPage.visit "store_2", (error) ->
                    return done error if error
                    expect(browser.storeCartPage.itemsQuantity()).toBe 1
                    expect(browser.storeCartPage.id()).toBe product3._id.toString()
                    expect(browser.storeCartPage.name()).toBe product3.name
                    expect(browser.storeCartPage.quantity()).toBe 1
                    done()
    ), 50000
