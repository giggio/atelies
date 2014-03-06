require './support/_specHelper'
Product   = require '../../app/models/product'
HomePage  = require './support/pages/homePage'
Q         = require 'q'

describe 'Home Search Product', ->
  page = store1 = product1 = product2 = null
  before ->
    page = new HomePage()
    cleanDB()
    .then ->
      product1 = generator.product.a()
      product2 = generator.product.d()
      product1.save()
      product2.save()
      store1 = generator.store.a()
      store1.save()
    .then whenServerLoaded
    .then page.visit
    .then -> page.searchProductsText 'cool'
    .then page.clickDoSearchProducts
  it 'shows product', -> page.searchProductsLength().then().should.become 1
  it 'links picture to product 2', -> page.productLink(product2._id).then (href) -> href.endsWith(product2.slug).should.be.true
