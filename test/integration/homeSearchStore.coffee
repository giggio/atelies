require './support/_specHelper'
Product   = require '../../app/models/product'

describe 'Home Search Store', ->
  browser = store1 = store2 = store3 = product1 = product2 = null
  before (done) ->
    browser = newBrowser()
    cleanDB (error) ->
      if error
        return done error
      product1 = generator.product.b()
      product2 = generator.product.c()
      product1.save()
      product2.save()
      store1 = generator.store.a()
      store2 = generator.store.b()
      store3 = generator.store.c()
      store1.save()
      store2.save()
      store3.save()
      whenServerLoaded ->
        page = browser.homePage
        page.visit ->
          page.clickSearchStores ->
            page.searchStoresText 'very'
            page.clickDoSearchStores ->
              browser.reload done
  after ->
    browser.destroy()
  it 'shows stores', ->
    expect(browser.queryAll('#stores .store').length).to.equal 1
  it 'links picture to store 1', ->
    expect(browser.query("#store#{store3._id} .link").href.endsWith store3.slug).to.be.true
