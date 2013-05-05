require './support/_specHelper'
Store     = require '../../models/store'
Product   = require '../../models/product'

describe 'Store shopping cart page (manage)', ->
  store = product1 = product2 = store2 = product3 = browser = null
  afterEach -> browser.destroy() if browser?
  before (done) =>
    cleanDB (error) ->
      return done error if error
      store = generator.store.a()
      store.save()
      product1 = generator.product.a()
      product1.save()
      product2 = generator.product.b()
      product2.save()
      done()
  it 'with two items, when remove on item', (done) ->
    @timeout 60000
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
              #it 'is at the cart location', ->
              expect(browser.location.toString()).to.equal "http://localhost:8000/store_1#cart"
              browser.reload ->
                browser.storeCartPage.removeItem product1, ->
                  #it 'shows a cart with one item', ->
                  expect(browser.storeCartPage.itemsQuantity()).to.equal 1
                  #it 'shows item id', ->
                  expect(browser.storeCartPage.id()).to.equal product2._id.toString()
                  done()
  it 'can set quantity', (done) ->
      @timeout 60000
      browser = newBrowser()
      whenServerLoaded ->
        browser.storeProductPage.visit 'store_1', 'name_1', (error) ->
          return done error if error
          browser.storeProductPage.purchaseItem ->
            return done error if error
            browser.reload ->
              browser.storeCartPage.updateQuantity product1, 3, (error) ->
                return done error if error
                #browser = newBrowser browser
                browser.storeCartPage.visit 'store_1', ->
                  #it 'is at the cart location', ->
                  expect(browser.location.toString()).to.equal "http://localhost:8000/store_1#cart"
                  #it 'shows a cart with one item', ->
                  expect(browser.storeCartPage.itemsQuantity()).to.equal 1
                  #it 'shows quantity of two', ->
                  expect(browser.storeCartPage.quantity()).to.equal 3
                  done()
  it 'when setting quantity to incorrect value a validation error appears', (done) ->
      browser = newBrowser()
      whenServerLoaded ->
        browser.storeProductPage.visit 'store_1', 'name_1', (error) ->
          return done error if error
          browser.storeProductPage.purchaseItem ->
            return done error if error
            browser.reload ->
              browser.storeCartPage.updateQuantity product1, 'abc', ->
                #it 'shows error message', ->
                expect(browser.text("label[for='quantity#{product1._id}']")).to.equal "Apenas números permitidos."
                #it 'shows original quantity', (done) ->
                browser.storeCartPage.visit 'store_1', (error) ->
                  return done error if error
                  expect(browser.storeCartPage.quantity()).to.equal 1
                  done()
  it 'clearing cart', (done) ->
    browser = newBrowser()
    whenServerLoaded ->
      browser.storeProductPage.visit 'store_1', 'name_1', (error) ->
        return done error if error
        browser.storeProductPage.purchaseItem ->
          return done error if error
          browser.reload ->
            browser.storeCartPage.clearCart ->
              #it 'shows an empty cart', ->
              expect(browser.storeCartPage.itemsQuantity()).to.equal 0
              done()
