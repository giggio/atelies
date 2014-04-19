require './support/_specHelper'
Product                         = require '../../app/models/product'
Order                           = require '../../app/models/order'
StoreFinishOrderPaymentPage     = require './support/pages/storeFinishOrderPaymentPage'
StoreFinishOrderShippingPage    = require './support/pages/storeFinishOrderShippingPage'
StoreCartPage                   = require './support/pages/storeCartPage'
StoreProductPage                = require './support/pages/storeProductPage'
_                               = require 'underscore'

describe 'Store Finish Order: Payment', ->
  page = storeFinishOrderShippingPage = storeCartPage = storeProductPage = store = product1 = product2 = product3 = store2 = user1 = p1Inventory = p2Inventory = null
  before ->
    page = new StoreFinishOrderPaymentPage
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
      .then -> page.loginFor user1._id
      .then -> storeProductPage.visit 'store_1', 'name_1'
      .then storeProductPage.purchaseItem
      .then storeCartPage.clickFinishOrder
      .then storeFinishOrderShippingPage.clickSedexOption
      .then storeFinishOrderShippingPage.clickContinue
    it 'should show options for payment type with Paypal already selected', ->
      page.paymentTypes().then (pts) ->
        pts.length.should.equal 3
        selectedPaymentType = _.findWhere pts, selected:true
        selectedPaymentType.value.should.equal 'paypal'
    it 'should be at payment page', -> page.currentUrl().should.become "http://localhost:8000/#{store.slug}/finishOrder/payment"

  describe 'payment info for store without pagseguro enabled', ->
    before ->
      cleanDB().then ->
        store = generator.store.c()
        store.save()
        product1 = generator.product.a()
        product1.storeSlug = store.slug
        product1.storeName = store.name
        product1.save()
        user1 = generator.user.d()
        user1.save()
        page.clearLocalStorage()
      .then -> page.loginFor user1._id
      .then -> storeProductPage.visit 'store_3', 'name_1'
      .then storeProductPage.purchaseItem
      .then storeCartPage.clickFinishOrder
      .then storeFinishOrderShippingPage.clickSedexOption
      .then storeFinishOrderShippingPage.clickContinue
    it 'should show options for payment type with direct payment already selected', ->
      page.paymentTypes().then (pts) ->
        pts.length.should.equal 1
        selectedPaymentType = _.findWhere pts, selected:true
        selectedPaymentType.value.should.equal 'directSell'
    it 'should be at payment page', -> page.currentUrl().should.become "http://localhost:8000/#{store.slug}/finishOrder/payment"
