require './support/_specHelper'
SiteAdminStoresReportsPage      = require './support/pages/siteAdminStoresReportsPage'
Store                           = require '../../app/models/store'
Q                               = require 'q'

describe 'Site Admin Stores Reports page', ->
  page = adminUser = customer = store2 = store1 = userSeller = product1 = product2 = order1 = order2 = null
  before ->
    page = new SiteAdminStoresReportsPage()
    whenServerLoaded()
  setDb = ->
    cleanDB().then ->
      adminUser = generator.user.a()
      adminUser.isAdmin = true
      adminUser.save()
      store1 = generator.store.a()
      store1.categories = [ 'abc', 'def' ]
      store1.isFlyerAuthorized = undefined
      store1.save()
      store2 = generator.store.b()
      store2.isFlyerAuthorized = undefined
      store2.save()
      store3 = generator.store.c()
      store3.isFlyerAuthorized = true
      store3.save()
      store4 = generator.store.d()
      store4.isFlyerAuthorized = false
      store4.save()
      product1 = generator.product.a()
      product1.save()
      product2 = generator.product.b()
      product2.save()
      customer = generator.user.d()
      customer.save()
      order1 = generator.order.a()
      order1.customer = customer
      order1.deliveryAddress = customer.deliveryAddress
      order1.store = store1
      order1.items[0].product = product1
      order1.save()
      order2 = generator.order.b()
      order2.customer = customer
      order2.deliveryAddress = customer.deliveryAddress
      order2.store = store1
      order2.items[0].product = product2
      order2.save()
      userSeller = generator.user.a()
      userSeller.stores.push store1
      userSeller.stores.push store2
      userSeller.save()

  describe 'shows report with 4 stores', ->
    before ->
      setDb()
      .then -> page.loginFor adminUser._id
      .then page.visit
    it 'shows 4 stores', -> page.storesQuantity().should.eventually.equal 4
    it 'shows correct info for first store', ->
      page.storeIn(0)
      .then (store) ->
        store.name.should.equal store1.name
        store.email.should.equal store1.email
        store.url.should.equal "http://localhost:8000/#{store1.slug}"
        store.sellerName.should.equal userSeller.name
        store.sellerEmail.should.equal userSeller.email
        store.numberOfOrders.should.equal 2
        store.numberOfProducts.should.equal 2
        store.categories.should.equal 'abc, def'
