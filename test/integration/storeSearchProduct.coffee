require './support/_specHelper'
Product        = require '../../app/models/product'
StoreHomePage  = require './support/pages/storeHomePage'

xdescribe 'Store Search Product', ->
  page = store1 = product1 = product2 = null
  before (done) ->
    page = new StoreHomePage()
    cleanDB (error) ->
      if error
        return done error
      product1 = generator.product.a()
      product2 = generator.product.d()
      product1.save()
      product2.save()
      store1 = generator.store.a()
      store1.save()
      whenServerLoaded ->
        page.visit store1.slug, ->
          page.searchProductsText 'cool'
          page.clickDoSearchProducts done
  it 'shows product', (done) ->
    page.productsLength (l) ->
      l.should.equal 1
      done()
  it 'links picture to product 2', (done) ->
    page.productLink product2._id, (href) ->
      href.endsWith(product2.slug).should.be.true
      done()
