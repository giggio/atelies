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
      store1 = generator.store.a()
      Q.all [Q.ninvoke(store1, 'save'), Q.ninvoke(product1, 'save'), Q.ninvoke(product2, 'save') ]
    .then -> page.visit()
    .then -> page.searchProductsText 'cool'
    .then page.clickDoSearchProducts
  it 'shows product', -> page.searchProductsLength().should.become 1
  it 'links picture to product 2', -> page.productLink(product2._id).then (href) -> href.endsWith(product2.slug).should.be.true
