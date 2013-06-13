require './support/_specHelper'
Store               = require '../../app/models/store'
Product             = require '../../app/models/product'
StoreCartPage       = require './support/pages/storeCartPage'
page                = new StoreCartPage()
StoreProductPage    = require './support/pages/storeProductPage'
storeProductPage    = new StoreProductPage page

describe 'Store shopping cart page', ->
  store = product1 = product2 = store2 = product3 = null
  after (done) -> page.closeBrowser done
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
      whenServerLoaded done

  describe 'show empty cart', ->
    before (done) =>
      page.clearLocalStorage ->
        page.visit "store_1", done
    it 'does not show the cart items table', (done) ->
      page.cartItemsExists (itDoes) ->
        itDoes.should.be.false
        done()

  describe 'when add one item to cart', ->
    before (done) ->
      page.clearLocalStorage ->
        storeProductPage.visit 'store_1', 'name_1', ->
          storeProductPage.purchaseItem done
    it 'shows product info', (done) ->
      page.itemsQuantity (q) ->
        q.should.equal 1
        page.id (id) ->
          id.should.equal product1._id.toString()
          page.name (n) ->
            n.should.equal product1.name
            page.quantity (q) ->
              q.should.equal 1
              done()
    it 'is at the cart location', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/store_1#cart"
        done()

  describe 'when add two items to cart', ->
    before (done) ->
      page.clearLocalStorage ->
        storeProductPage.visit 'store_1', 'name_1', ->
          storeProductPage.purchaseItem ->
            storeProductPage.visit 'store_1', 'name_1', ->
              storeProductPage.purchaseItem done
    it 'is at the cart location', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/store_1#cart"
        done()
    it 'shows a cart with one item', (done) ->
      page.itemsQuantity (q) ->
        q.should.equal 1
        done()
    it 'shows quantity of two', (done) ->
      page.quantity (q) ->
        q.should.equal 2
        done()
    it 'shows totals', (done) ->
      page.totalPrice (totalPrice) ->
        totalPrice.should.equal "R$ 22,20"
        done()
  
  describe 'when working with a cart with products from different stores', ->
    before (done) =>
      page.clearLocalStorage ->
        storeProductPage.visit 'store_1', 'name_1', ->
          storeProductPage.purchaseItem ->
            storeProductPage.visit 'store_2', 'name_3', ->
              storeProductPage.purchaseItem done
    it 'on the 1st store it shows only the first store products', (done) ->
      page.visit "store_1", ->
        page.itemsQuantity (q) ->
          q.should.equal 1
          page.id (id) ->
            id.should.equal product1._id.toString()
            page.name (n) ->
              n.should.equal product1.name
              page.quantity (q) ->
                q.should.equal 1
                done()
    it 'on the 2st store it shows only the second store products', (done) ->
      page.visit "store_2", ->
        page.itemsQuantity (q) ->
          q.should.equal 1
          page.id (id) ->
            id.should.equal product3._id.toString()
            page.name (n) ->
              n.should.equal product3.name
              page.quantity (q) ->
                q.should.equal 1
                done()
