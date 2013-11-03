require './support/_specHelper'
Store     = require '../../app/models/store'
Product   = require '../../app/models/product'
User      = require '../../app/models/user'
Page      = require './support/pages/adminStorePage'

describe 'Admin Show Store page', ->
  page = product1 = product2 = store = userSeller = null
  before (done) -> whenServerLoaded done
  describe 'viewing store products', (done) ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
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
        page.loginFor userSeller._id, ->
          page.visit store.slug, done
    it 'shows store products', (done) ->
      page.products (products) =>
        products.length.should.equal 2
        products[0].name.should.equal product1.name
        products[0].picture.should.equal product1.picture + "_thumb150x150"
        done()
    it 'shows store name', (done) ->
      page.storeName (name) ->
        name.should.equal store.name
        done()
    it 'allows to create new product', (done) ->
      page.createProductLink (link) =>
        link.endsWith("admin/createProduct/#{store.slug}").should.be.true
        done()
    it 'allows to edit products', (done) ->
      page.products (products) ->
        products[0].manageLink.should.equal "http://localhost:8000/admin/manageProduct/#{store.slug}/#{product1._id}"
        products[1].manageLink.should.equal "http://localhost:8000/admin/manageProduct/#{store.slug}/#{product2._id}"
        done()
