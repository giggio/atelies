require './support/_specHelper'
Product                         = require '../../app/models/product'
Order                           = require '../../app/models/order'
StoreFinishOrderPaymentPage     = require './support/pages/storeFinishOrderPaymentPage'
StoreFinishOrderShippingPage    = require './support/pages/storeFinishOrderShippingPage'
StoreCartPage                   = require './support/pages/storeCartPage'
StoreProductPage                = require './support/pages/storeProductPage'
StoreFinishOrderSummaryPage     = require './support/pages/storeFinishOrderSummaryPage'
Q                               = require 'q'

describe 'Store Finish Order: Summary', ->
  page = storeFinishOrderPaymentPage = storeFinishOrderShippingPage = storeCartPage = storeProductPage = store = product1 = product2 = product3 = store2 = user1 = p1Inventory = p2Inventory = null
  before ->
    storeFinishOrderPaymentPage = new StoreFinishOrderPaymentPage
    page = new StoreFinishOrderSummaryPage
    storeFinishOrderShippingPage = new StoreFinishOrderShippingPage page
    storeCartPage = new StoreCartPage page
    storeProductPage = new StoreProductPage page
    whenServerLoaded()

  describe 'payment info', ->
    before ->
      cleanDB().then ->
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
        page.clearLocalStorage()
        .then page.loginFor user1._id
        .then -> storeProductPage.visit 'store_1', 'name_1'
        .then storeProductPage.purchaseItem
        .then -> storeProductPage.visit 'store_1', 'name_2'
        .then storeProductPage.purchaseItem
        .then storeCartPage.clickFinishOrder
        .then storeFinishOrderShippingPage.clickSedexOption
        .then storeFinishOrderShippingPage.clickContinue
        .then storeFinishOrderPaymentPage.clickSelectPaymentType
    it 'should show summary of sale', ->
      page.summaryOfSale().then (s) ->
        s.shippingCost.should.equal 'R$ 20,10'
        s.productsInfo.should.equal '2 produtos'
        s.totalProductsPrice.should.equal 'R$ 33,30'
        s.totalSaleAmount.should.equal 'R$ 53,40'
        a = s.address
        userAddress = user1.deliveryAddress
        a.street.should.equal userAddress.street
        a.street2.should.equal userAddress.street2
        a.city.should.equal userAddress.city
        a.state.should.equal userAddress.state
        a.zip.should.equal userAddress.zip
    it 'should be at summary page', -> page.currentUrl().should.become "http://localhost:8000/#{store.slug}/finishOrder/summary"

  describe 'completing the payment with products with and without inventory and with products with and without shipping', ->
    before ->
      cleanDB().then ->
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
        page.clearLocalStorage()
        .then page.loginFor user1._id
        .then -> storeProductPage.visit 'store_2', 'name_3'
        .then storeProductPage.purchaseItem
        .then -> storeProductPage.visit 'store_2', 'name_1'
        .then storeProductPage.purchaseItem
        .then storeCartPage.clickFinishOrder
        .then storeFinishOrderShippingPage.clickSedexOption
        .then storeFinishOrderShippingPage.clickContinue
        .then storeFinishOrderPaymentPage.clickSelectPaymentType
        .then page.clickCompleteOrder
    it 'should have stored a new order on db', ->
      Q.ninvoke Order, "find"
      .then (orders) ->
        orders.length.should.equal 1
        order = orders[0]
        order.customer.toString().should.equal user1._id.toString()
        order.store.toString().should.equal store2._id.toString()
        order.items.length.should.equal 2
        order.shippingCost.should.equal 20.1
        order.totalProductsPrice.should.equal product3.price + product1.price
        order.totalSaleAmount.should.equal order.totalProductsPrice + order.shippingCost
        order.deliveryAddress.toJSON().should.be.like user1.deliveryAddress.toJSON()
        order.paymentType.should.equal 'directSell'
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
    it 'did not touch the inventory', ->
      Q.ninvoke Product, "findById", product3._id
      .then (p) -> expect(p.inventory).to.be.undefined
    it 'subtracted one item from the inventory of each product', ->
      Q.ninvoke(Product, "findById", product1._id).then (p1) -> p1.inventory.should.equal p1Inventory - 1
    it 'should be at order completed page', -> page.currentUrl().should.become "http://localhost:8000/#{store2.slug}/finishOrder/orderFinished"

  describe 'completing the payment with product without shipping', ->
    before ->
      cleanDB (error) ->
        store = generator.store.a()
        store.save()
        product1 = generator.product.a()
        product1.shipping.applies = false
        product1.save()
        p1Inventory = product1.inventory
        user1 = generator.user.d()
        user1.save()
        page.clearLocalStorage()
        .then -> page.loginFor user1._id
        .then -> storeProductPage.visit 'store_1', 'name_1'
        .then storeProductPage.purchaseItem
        .then storeCartPage.clickFinishOrder
        .then storeFinishOrderPaymentPage.clickSelectDirectPayment
        .then storeFinishOrderPaymentPage.clickSelectPaymentType
        .then page.clickCompleteOrder
    it 'should have stored a new order on db with direct payment', ->
      Q.ninvoke Order, "find"
      .then (orders) ->
        orders.length.should.equal 1
        order = orders[0]
        order.customer.toString().should.equal user1._id.toString()
        order.store.toString().should.equal store._id.toString()
        order.items.length.should.equal 1
        order.shippingCost.should.equal 0
        order.totalProductsPrice.should.equal product1.price
        order.totalSaleAmount.should.equal order.totalProductsPrice + order.shippingCost
        order.deliveryAddress.toJSON().should.be.like user1.deliveryAddress.toJSON()
        order.paymentType.should.equal 'directSell'
        p1 = order.items[0]
        p1.product.toString().should.equal product1._id.toString()
        p1.price.should.equal product1.price
        p1.quantity.should.equal 1
        p1.totalPrice.should.equal product1.price
    it 'subtracted one item from the inventory of the product', ->
      Q.ninvoke(Product, "findById", product1._id).then (p1) -> p1.inventory.should.equal p1Inventory - 1
    it 'should be at order completed page', -> page.currentUrl().should.become "http://localhost:8000/#{store.slug}/finishOrder/orderFinished"
