require './support/_specHelper'
Product   = require '../../app/models/product'
HomePage  = require './support/pages/homePage'

describe 'Home page', ->
  page = store1 = store2 = product1 = product2 = null
  before (done) ->
    page = new HomePage()
    cleanDB (error) ->
      return done error if error?
      product1 = generator.product.b()
      product2 = generator.product.c()
      for i in [0..9]
        p = generator.product.a()
        p.name+=i
        p.save()
      product1.save()
      product2.save()
      store1 = generator.store.a()
      store2 = generator.store.b()
      store1.save()
      store2.save()
      for i in [0..9]
        s = generator.store.a()
        s.name+=i
        s.save()
      whenServerLoaded ->
        page.visit done
  it 'has twelve products', (done) ->
    page.productsLength (l) ->
      l.should.equal 12
      done()
  it 'shows product 1', (done) ->
    page.product product1._id, (p) ->
      p._id.should.equal product1._id.toString()
      p.storeName.should.equal product1.storeName
      p.picture.should.equal product1.picture + "_thumb150x150"
      p.slug.endsWith(product1.slug).should.be.true
      done()
  it 'shows stores', (done) ->
    page.storesLength (l) ->
      l.should.equal 12
      done()
  it 'links picture to store 1', (done) ->
    page.storeLink store1._id, (href) ->
      href.endsWith(store1.slug).should.be.true
      done()
