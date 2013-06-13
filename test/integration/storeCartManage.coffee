require './support/_specHelper'
Store               = require '../../app/models/store'
Product             = require '../../app/models/product'
StoreCartPage       = require './support/pages/storeCartPage'
StoreProductPage    = require './support/pages/storeProductPage'

describe 'Store shopping cart page (manage)', ->
  page = storeProductPage = store = product1 = product2 = store2 = product3 = null
  after (done) -> page.closeBrowser done
  before (done) =>
    page = new StoreCartPage()
    storeProductPage = new StoreProductPage page
    cleanDB (error) ->
      return done error if error
      store = generator.store.a()
      store.save()
      product1 = generator.product.a()
      product1.save()
      product2 = generator.product.b()
      product2.save()
      whenServerLoaded done

  describe 'with two items, when remove one item', ->
    before (done) ->
      page.clearLocalStorage ->
        storeProductPage.visit 'store_1', 'name_1', ->
          storeProductPage.purchaseItem ->
            storeProductPage.visit 'store_1', 'name_2', ->
              storeProductPage.purchaseItem ->
                page.itemsQuantity (q) ->
                  q.should.equal 2
                  page.removeItem product1, done
    it 'shows a cart with one item', (done) ->
      page.itemsQuantity (q) ->
        q.should.equal 1
        done()
    it 'shows item id', (done) ->
      page.id (id) ->
        id.should.equal product2._id.toString()
        done()

  describe 'when setting quantity', ->
    before (done) ->
      page.clearLocalStorage ->
        storeProductPage.visit 'store_1', 'name_1', ->
          storeProductPage.purchaseItem ->
            page.updateQuantity product1, 3, ->
              page.visit 'store_1', done
    it 'is at the cart location', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/store_1#cart"
        done()
    it 'shows a cart with one item', (done) ->
      page.itemsQuantity (q) ->
        q.should.equal 1
        done()
    it 'shows quantity of three', (done) ->
      page.quantity (q) ->
        q.should.equal 3
        done()

  describe 'when setting quantity to incorrect value', ->
    before (done) ->
      page.clearLocalStorage ->
        storeProductPage.visit 'store_1', 'name_1', ->
          storeProductPage.purchaseItem ->
            page.updateQuantity product1, 'abc', done
    it 'shows error message', (done) ->
      page.errorMessageForSelector '.quantity', (t) ->
        t.should.equal "A quantidade deve ser um número."
        done()
    it 'shows original quantity', (done) ->
      page.visit 'store_1', ->
        page.quantity (q) ->
          q.should.equal 1
          done()

  describe 'clearing cart', ->
    before (done) ->
      page.clearLocalStorage ->
        storeProductPage.visit 'store_1', 'name_1', ->
          storeProductPage.purchaseItem ->
            page.clearCart done
    it 'shows an empty cart', (done) ->
      page.itemsQuantity (q) ->
        q.should.equal 0
        done()
