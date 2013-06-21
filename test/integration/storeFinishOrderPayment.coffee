require './support/_specHelper'
Product                         = require '../../app/models/product'
Order                           = require '../../app/models/order'
StoreFinishOrderPaymentPage     = require './support/pages/storeFinishOrderPaymentPage'
StoreFinishOrderShippingPage    = require './support/pages/storeFinishOrderShippingPage'
StoreCartPage                   = require './support/pages/storeCartPage'
StoreProductPage                = require './support/pages/storeProductPage'

#TODO: review how to finish order with stores that dont have autocalculated shipping costs
xdescribe 'Store Finish Order: Payment', ->
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
                      storeFinishOrderShippingPage.clickSedexOption ->
                        storeFinishOrderShippingPage.clickContinue done
    it 'should show summary of sale', (done) ->
      page.summaryOfSale (s) ->
        s.shippingCost.should.equal 'R$ 43,60'
        s.productsInfo.should.equal '2 produtos'
        s.totalProductsPrice.should.equal 'R$ 33,30'
        s.totalSaleAmount.should.equal 'R$ 76,90'
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

  describe 'completing payment', ->
    before (done) ->
      page.clearCookies ->
        page.clearLocalStorage ->
          page.loginFor user1._id, ->
            storeProductPage.visit 'store_1', 'name_1', ->
              storeProductPage.purchaseItem ->
                storeProductPage.visit 'store_1', 'name_2', ->
                  storeProductPage.purchaseItem ->
                    storeCartPage.updateQuantity product2, 2, ->
                      storeCartPage.clickFinishOrder ->
                        storeFinishOrderShippingPage.clickSedexOption ->
                          storeFinishOrderShippingPage.clickContinue ->
                            page.clickCompleteOrder ->
                              page.waitForUrl "http://localhost:8000/#{store.slug}#finishOrder/orderFinished", ->
                                waitSeconds 1, done
    it 'should show have stored a new order on db', (done) ->
      Order.find (err, orders) ->
        throw err if err
        orders.length.should.equal 1
        order = orders[0]
        order.customer.toString().should.equal user1._id.toString()
        order.store.toString().should.equal store._id.toString()
        order.items.length.should.equal 2
        order.shippingCost.should.equal 1
        order.totalProductsPrice.should.equal product1.price+product2.price*2
        order.totalSaleAmount.should.equal order.totalProductsPrice+order.shippingCost
        order.deliveryAddress.toJSON().should.be.like user1.deliveryAddress.toJSON()
        p1 = order.items[0]
        p2 = order.items[1]
        p1.product.toString().should.equal product1._id.toString()
        p1.price.should.equal product1.price
        p1.quantity.should.equal 1
        p1.totalPrice.should.equal product1.price
        p2.product.toString().should.equal product2._id.toString()
        p2.price.should.equal product2.price
        p2.quantity.should.equal 2
        p2.totalPrice.should.equal product2.price * 2
        done()
    it 'should have subtracted one item from the inventory of each product', (done) ->
      Product.findById product1._id, (err, p1) ->
        throw err if err
        p1.inventory.should.equal p1Inventory - 1
        Product.findById product2._id, (err, p2) ->
          throw err if err
          p2.inventory.should.equal p2Inventory - 2
          done()
    it 'should be at order completed page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/#{store.slug}#finishOrder/orderFinished"
        done()
