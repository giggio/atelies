require './support/_specHelper'
Product        = require '../../app/models/product'
StoreHomePage  = require './support/pages/storeHomePage'

describe 'Store Search Product', ->
  page = store1 = product1 = product2 = product3 = null
  before ->
    page = new StoreHomePage()
    cleanDB().then ->
      product1 = generator.product.a()
      product2 = generator.product.d()
      product3 = generator.product.c()
      product1.save()
      product2.save()
      product3.save()
      store1 = generator.store.a()
      store1.save()
    .then -> whenServerLoaded
    .then -> page.visit store1.slug
    .then -> page.searchProductsText 'name'
    .then page.clickDoSearchProducts
  it 'shows product only from the store', -> page.searchProductsLength().should.become 1
  it 'links picture to product 1', -> page.productLink(product1._id).then (href) -> href.endsWith(product1.slug).should.be.true
