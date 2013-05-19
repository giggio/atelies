require './support/_specHelper'
Store     = require '../../app/models/store'
Product   = require '../../app/models/product'

describe 'Store shopping cart page (manage)', ->
  page = store = product1 = product2 = store2 = product3 = browser = null
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
  describe 'with two items, when remove one item', ->
    @timeout 60000
    before (done) ->
      browser = newBrowser()
      page = browser.storeCartPage
      whenServerLoaded ->
        browser.storeProductPage.visit 'store_1', 'name_1', (error) ->
          return done error if error
          browser.storeProductPage.purchaseItem ->
            browser.storeProductPage.visit 'store_1', 'name_2', (error) ->
              return done error if error
              browser.storeProductPage.purchaseItem ->
                browser.reload ->
                  page.itemsQuantity().should.equal 2
                  page.removeItem product1, done
    it 'shows a cart with one item', ->
      page.itemsQuantity().should.equal 1
    xit 'shows item id', ->
      page.id().should.equal product2._id.toString()

  describe 'when setting quantity', ->
    before (done) ->
      @timeout 60000
      browser = newBrowser()
      page = browser.storeCartPage
      whenServerLoaded ->
        browser.storeProductPage.visit 'store_1', 'name_1', (error) ->
          return done error if error
          browser.storeProductPage.purchaseItem ->
            return done error if error
            browser.reload ->
              page.updateQuantity product1, 3, (error) ->
                return done error if error
                page.visit 'store_1', done
      it 'is at the cart location', ->
        expect(browser.location.toString()).to.equal "http://localhost:8000/store_1#cart"
      it 'shows a cart with one item', ->
        expect(browser.storeCartPage.itemsQuantity()).to.equal 1
      it 'shows quantity of three', ->
        expect(browser.storeCartPage.quantity()).to.equal 3

  describe 'when setting quantity to incorrect value', ->
    before (done) ->
      browser = newBrowser()
      page = browser.storeCartPage
      whenServerLoaded ->
        browser.storeProductPage.visit 'store_1', 'name_1', (error) ->
          return done error if error
          browser.storeProductPage.purchaseItem ->
            return done error if error
            browser.reload ->
              browser.storeCartPage.updateQuantity product1, 'abc', done
    it 'shows error message', ->
      page.errorMessageFor('quantity').should.equal "A quantidade deve ser um número."
    xit 'shows original quantity', (done) ->
      browser.storeCartPage.visit 'store_1', (error) ->
        return done error if error
        expect(browser.storeCartPage.quantity()).to.equal 1
        done()

  describe 'clearing cart', ->
    before (done) ->
      browser = newBrowser()
      whenServerLoaded ->
        browser.storeProductPage.visit 'store_1', 'name_1', (error) ->
          return done error if error
          browser.storeProductPage.purchaseItem ->
            return done error if error
            browser.reload ->
              browser.storeCartPage.clearCart done
    it 'shows an empty cart', ->
      expect(browser.storeCartPage.itemsQuantity()).to.equal 0
