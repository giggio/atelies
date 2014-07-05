require './support/_specHelper'
Store     = require '../../app/models/store'
Product   = require '../../app/models/product'
User      = require '../../app/models/user'
Page      = require './support/pages/adminStorePage'
Q         = require 'q'

describe 'Admin Show Store page', ->
  page = product1 = product2 = store = userSeller = null
  describe 'viewing store products', ->
    before ->
      cleanDB().then ->
        page = new Page()
        store = generator.store.a()
        product1 = generator.product.a()
        product2 = generator.product.b()
        userSeller = generator.user.c()
        userSeller.stores.push store
        Q.all [Q.ninvoke(store, 'save'), Q.ninvoke(product1, 'save'), Q.ninvoke(product2, 'save'), Q.ninvoke(userSeller, 'save') ]
      .then -> page.loginFor userSeller._id
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

  describe "can't see a store if you don't own it", ->
    before ->
      cleanDB().then ->
        page = new Page()
        store = generator.store.a()
        userSeller = generator.user.c()
        Q.all [Q.ninvoke(store, 'save'), Q.ninvoke(userSeller, 'save') ]
      .then -> page.loginFor userSeller._id
      .then -> page.visit store.slug
    it "shows store can't be shown message", -> page.getDialogMsg().should.become "Você não tem permissão para alterar essa loja. Entre em contato diretamente com o administrador."
    it 'redirects user to admin page', -> page.currentUrl().should.become "http://localhost:8000/admin"
