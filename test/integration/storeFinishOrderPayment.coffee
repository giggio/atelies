require './support/_specHelper'
Store                           = require '../../app/models/store'
Product                         = require '../../app/models/product'
StoreFinishOrderPaymentPage     = require './support/pages/storeFinishOrderPaymentPage'
StoreFinishOrderShippingPage    = require './support/pages/storeFinishOrderShippingPage'
StoreCartPage                   = require './support/pages/storeCartPage'
StoreProductPage                = require './support/pages/storeProductPage'

describe 'Store Finish Order: Payment', ->
  page = storeFinishOrderShippingPage = storeCartPage = storeProductPage = store = product1 = product2 = store2 = user1 = userIncompleteAddress = p1Inventory = p2Inventory = null
  after (done) -> page.closeBrowser done
  before (done) =>
    page = new StoreFinishOrderPaymentPage
    storeFinishOrderShippingPage = new StoreFinishOrderShippingPage page
    storeCartPage = new StoreCartPage page
    storeProductPage = new StoreProductPage page
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
      userIncompleteAddress = generator.user.a()
      userIncompleteAddress.save()
      whenServerLoaded done

  describe 'payment info', ->
    before (done) ->
      page.clearCookies ->
        page.clearLocalStorage ->
          page.loginFor user1._id, ->
            storeProductPage.visit 'store_1', 'name_1', ->
              storeProductPage.purchaseItem ->
                storeProductPage.visit 'store_1', 'name_2', ->
                  storeProductPage.purchaseItem ->
                    storeCartPage.clickFinishOrder ->
                      storeFinishOrderShippingPage.clickContinue done
    it 'should show summary of sale', (done) ->
      page.summaryOfSale (s) ->
        s.shippingCost.should.equal 'R$ 1,00'
        s.productsInfo.should.equal '2 produtos'
        s.totalProductsPrice.should.equal 'R$ 33,30'
        s.totalSaleAmount.should.equal 'R$ 34,30'
        a = s.address
        userAddress = user1.deliveryAddress
        a.street.should.equal userAddress.street
        a.street2.should.equal userAddress.street2
        a.city.should.equal userAddress.city
        a.state.should.equal userAddress.state
        a.zip.should.equal userAddress.zip
        done()
    it 'should be at payment page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/#{store.slug}#finishOrder/payment"
        done()

  xdescribe 'completing payment', ->
    before (done) ->
      page.clearCookies ->
        page.clearLocalStorage ->
          page.loginFor user1._id, ->
            storeProductPage.visit 'store_1', 'name_1', ->
              storeProductPage.purchaseItem ->
                storeProductPage.visit 'store_1', 'name_2', ->
                  storeProductPage.purchaseItem ->
                    storeCartPage.clickFinishOrder ->
                      storeFinishOrderShipping.clickContinue ->
                        page.clickCompleteOrder done
    it 'should show have stored a new order on db', (done) ->
      Order.find (orders) ->
        orders.length.should.equal 1
        order = orders[0]
        order.customer.should.equal user1
        order.products.length.should.equal 2
        p1 = order.products[0]
        p2 = order.products[1]
        p1._id.should.equal product1._id
        p1.quantity.should.equal 1
        p1.name.should.equal product1.name
        p1.price.should.equal product1.price
        done()
    it 'should have subtracted one item from the inventory of each product', (done) ->
      Product.findById product1._id, (p1) ->
        p1.inventory.should.equal p1Inventory - 1
        Product.findById product2._id, (p2) ->
          p2.inventory.should.equal p2Inventory - 1
          done()
    it 'should be at order completed page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/#{store.slug}#finishOrder/orderFinished"
        done()
