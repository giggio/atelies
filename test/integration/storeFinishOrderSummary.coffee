require './support/_specHelper'
Product                         = require '../../app/models/product'
Order                           = require '../../app/models/order'
StoreFinishOrderPaymentPage     = require './support/pages/storeFinishOrderPaymentPage'
StoreFinishOrderShippingPage    = require './support/pages/storeFinishOrderShippingPage'
StoreCartPage                   = require './support/pages/storeCartPage'
StoreProductPage                = require './support/pages/storeProductPage'
StoreFinishOrderSummaryPage     = require './support/pages/storeFinishOrderSummaryPage'

describe 'Store Finish Order: Summary', ->
  page = storeFinishOrderPaymentPage = storeFinishOrderShippingPage = storeCartPage = storeProductPage = store = product1 = product2 = product3 = store2 = user1 = p1Inventory = p2Inventory = null
  after (done) -> page.closeBrowser done
  before (done) =>
    storeFinishOrderPaymentPage = new StoreFinishOrderPaymentPage
    page = new StoreFinishOrderSummaryPage
    storeFinishOrderShippingPage = new StoreFinishOrderShippingPage page
    storeCartPage = new StoreCartPage page
    storeProductPage = new StoreProductPage page
    whenServerLoaded done

  describe 'payment info', ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        store = generator.store.a()
        store.save()
        product1 = generator.product.a()
        product1.save()
        p1Inventory = product1.inventory
        product2 = generator.product.b()
        product2.save()
        p2Inventory = product2.inventory
        user1 = generator.user.d()
        user1.save()
        page.clearLocalStorage ->
          page.loginFor user1._id, ->
            storeProductPage.visit 'store_1', 'name_1', ->
              storeProductPage.purchaseItem ->
                storeProductPage.visit 'store_1', 'name_2', ->
                  storeProductPage.purchaseItem ->
                    storeCartPage.clickFinishOrder ->
                      storeFinishOrderShippingPage.clickSedexOption ->
                        storeFinishOrderShippingPage.clickContinue ->
                          storeFinishOrderPaymentPage.clickSelectPaymentType done
    it 'should show summary of sale', (done) ->
      page.summaryOfSale (s) ->
        s.shippingCost.should.equal 'R$ 45,20'
        s.productsInfo.should.equal '2 produtos'
        s.totalProductsPrice.should.equal 'R$ 33,30'
        s.totalSaleAmount.should.equal 'R$ 78,50'
        a = s.address
        userAddress = user1.deliveryAddress
        a.street.should.equal userAddress.street
        a.street2.should.equal userAddress.street2
        a.city.should.equal userAddress.city
        a.state.should.equal userAddress.state
        a.zip.should.equal userAddress.zip
        done()
    it 'should be at summary page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/#{store.slug}#finishOrder/summary"
        done()

  describe 'completing the payment with manual shipping calculation and products with and without inventory', ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        store2 = generator.store.b()
        store2.save()
        product1 = generator.product.a()
        product1.storeSlug = store2.slug
        product1.storeName = store2.name
        product1.save()
        p1Inventory = product1.inventory
        product3 = generator.product.c()
        product3.save()
        user1 = generator.user.d()
        user1.save()
        page.clearLocalStorage ->
          page.loginFor user1._id, ->
            storeProductPage.visit 'store_2', 'name_3', ->
              storeProductPage.purchaseItem ->
                storeProductPage.visit 'store_2', 'name_1', ->
                  storeProductPage.purchaseItem ->
                    storeCartPage.clickFinishOrder ->
                      storeFinishOrderShippingPage.clickContinue ->
                        storeFinishOrderPaymentPage.clickSelectPaymentType ->
                          page.clickCompleteOrder ->
                            waitSeconds 2, done
    it 'should have stored a new order on db', (done) ->
      Order.find (err, orders) ->
        throw err if err
        orders.length.should.equal 1
        order = orders[0]
        order.customer.toString().should.equal user1._id.toString()
        order.store.toString().should.equal store2._id.toString()
        order.items.length.should.equal 2
        order.shippingCost.should.equal 0
        order.totalProductsPrice.should.equal product3.price + product1.price
        order.totalSaleAmount.should.equal order.totalProductsPrice
        order.deliveryAddress.toJSON().should.be.like user1.deliveryAddress.toJSON()
        p3 = order.items[0]
        p3.product.toString().should.equal product3._id.toString()
        p3.price.should.equal product3.price
        p3.quantity.should.equal 1
        p3.totalPrice.should.equal product3.price
        p1 = order.items[1]
        p1.product.toString().should.equal product1._id.toString()
        p1.price.should.equal product1.price
        p1.quantity.should.equal 1
        p1.totalPrice.should.equal product1.price
        done()
    it 'did not touch the inventory', (done) ->
      Product.findById product3._id, (err, p) ->
        throw err if err
        expect(p.inventory).to.be.undefined
        done()
    it 'subtracted one item from the inventory of each product', (done) ->
      Product.findById product1._id, (err, p1) ->
        throw err if err
        p1.inventory.should.equal p1Inventory - 1
        done()
    it 'should be at order completed page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/#{store2.slug}#finishOrder/orderFinished"
        done()
