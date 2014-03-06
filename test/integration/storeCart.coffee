require './support/_specHelper'
Store               = require '../../app/models/store'
Product             = require '../../app/models/product'
StoreCartPage       = require './support/pages/storeCartPage'
StoreProductPage    = require './support/pages/storeProductPage'
Q                   = require 'q'

describe 'Store shopping cart page', ->
  page = storeProductPage = store = product1 = product2 = store2 = product3 = null
  before ->
    page = new StoreCartPage()
    storeProductPage = new StoreProductPage page
    cleanDB()
    .then ->
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
    .then whenServerLoaded

  describe 'show empty cart', ->
    before ->
      page.clearLocalStorage()
      .then -> page.visit "store_1"
    it 'does not show the cart items table', -> page.cartItemsExists().should.eventually.be.false

  describe 'when add one item to cart', ->
    before ->
      page.clearLocalStorage()
      .then -> storeProductPage.visit 'store_1', 'name_1'
      .then storeProductPage.purchaseItem
    it 'shows product info', ->
      Q.all [
        page.itemsQuantity().should.become 1
        page.id().should.become product1._id.toString()
        page.name().should.become product1.name
        page.quantity().should.become 1
      ]
    it 'is at the cart location', -> page.currentUrl().should.become "http://localhost:8000/store_1/cart"

  describe 'when add two items to cart', ->
    before ->
      page.clearLocalStorage()
      .then -> storeProductPage.visit 'store_1', 'name_1'
      .then storeProductPage.purchaseItem
      .then -> storeProductPage.visit 'store_1', 'name_1'
      .then storeProductPage.purchaseItem
      .then -> storeProductPage.visit 'store_1', 'name_2'
      .then storeProductPage.purchaseItem
    it 'is at the cart location', -> page.currentUrl().should.become "http://localhost:8000/store_1/cart"
    it 'shows a cart with one item', -> page.itemsQuantity().should.become 2
    it 'shows quantity of two', -> page.quantity().should.become 2
    it 'shows total price for item with quantity of two', -> page.itemTotalPrice().should.become 'R$ 22,20'
    it 'shows totals', -> page.totalPrice().should.become "R$ 44,40"
  
  describe 'when working with a cart with products from different stores', ->
    before ->
      page.clearLocalStorage()
      .then -> storeProductPage.visit 'store_1', 'name_1'
      .then storeProductPage.purchaseItem
      .then -> storeProductPage.visit 'store_2', 'name_3'
      .then storeProductPage.purchaseItem
    it 'on the 1st store it shows only the first store products', ->
      page.visit "store_1"
      .then ->
        Q.all [
          page.itemsQuantity().should.become 1
          page.id().should.become product1._id.toString()
          page.name().should.become product1.name
          page.quantity().should.become 1
        ]
    it 'on the 2st store it shows only the second store products', ->
      page.visit "store_2"
      .then ->
        Q.all [
          page.itemsQuantity().should.become 1
          page.id().should.become product3._id.toString()
          page.name().should.become product3.name
          page.quantity().should.become 1
        ]
