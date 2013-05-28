require './support/_specHelper'
Product   = require '../../app/models/product'

describe 'Home Search Product', ->
  browser = store1 = product1 = product2 = null
  before (done) ->
    browser = newBrowser()
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
        page = browser.homePage
        page.visit ->
          page.searchProductsText 'cool'
          page.clickDoSearchProducts ->
            browser.reload done
  after ->
    browser.destroy()
  it 'shows product', ->
    expect(browser.queryAll('#productsSearchResults .product').length).to.equal 1
  it 'links picture to product 2', ->
    expect(browser.query("#product#{product2._id} .link").href.endsWith product2.slug).to.be.true
