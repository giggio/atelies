require './support/_specHelper'
Store     = require '../../app/models/store'
Product   = require '../../app/models/product'
User      = require '../../app/models/user'
Page      = require './support/pages/adminStorePage'

describe 'Admin Show Store page', ->
  page = product1 = product2 = store = userSeller = null
  before whenServerLoaded
  describe 'viewing store products', ->
    before ->
      cleanDB().then ->
        page = new Page()
        store = generator.store.a()
        store.save()
        product1 = generator.product.a()
        product1.save()
        product2 = generator.product.b()
        product2.save()
        userSeller = generator.user.c()
        userSeller.stores.push store
        userSeller.save()
        page.loginFor userSeller._id
      .then -> page.visit store.slug
    it 'shows store products', ->
      page.products().then (products) ->
        products.length.should.equal 2
        products[0].name.should.equal product1.name
        products[0].picture.should.equal product1.picture + "_thumb150x150"
    it 'shows store name', -> page.storeName().should.become store.name
    it 'allows to create new product', -> page.createProductLink().then (link) -> link.endsWith("admin/createProduct/#{store.slug}").should.be.true
    it 'allows to edit products', ->
      page.products().then (products) ->
        products[0].manageLink.should.equal "http://localhost:8000/admin/manageProduct/#{store.slug}/#{product1._id}"
        products[1].manageLink.should.equal "http://localhost:8000/admin/manageProduct/#{store.slug}/#{product2._id}"
