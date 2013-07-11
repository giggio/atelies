require './support/_specHelper'
Product        = require '../../app/models/product'
StoreHomePage  = require './support/pages/storeHomePage'

describe 'Store Search Product', ->
  page = store1 = product1 = product2 = product3 = null
  before (done) ->
    page = new StoreHomePage()
    cleanDB (error) ->
      if error
        return done error
      product1 = generator.product.a()
      product2 = generator.product.d()
      product3 = generator.product.c()
      product1.save()
      product2.save()
      product3.save()
      store1 = generator.store.a()
      store1.save()
      whenServerLoaded ->
        page.visit store1.slug, ->
          page.searchProductsText 'name'
          page.clickDoSearchProducts done
  it 'shows product only from the store', (done) ->
    page.searchProductsLength (l) ->
      l.should.equal 1
      done()
  it 'links picture to product 1', (done) ->
    page.productLink product1._id, (href) ->
      href.endsWith(product1.slug).should.be.true
      done()
