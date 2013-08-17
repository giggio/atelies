require './support/_specHelper'
Product                 = require '../../app/models/product'
HomePage                = require './support/pages/homePage'

describe 'Home Search Store', ->
  page = store1 = store2 = store3 = product1 = product2 = null
  after (done) -> page.closeBrowser done
  before (done) ->
    page = new HomePage()
    cleanDB (error) ->
      if error
        return done error
      product1 = generator.product.b()
      product2 = generator.product.c()
      product1.save()
      product2.save()
      store1 = generator.store.a()
      store2 = generator.store.b()
      store3 = generator.store.d()
      store4 = generator.store.e()
      store1.save()
      store2.save()
      store3.save()
      store4.save()
      whenServerLoaded ->
        page.visit ->
          page.clickSearchStores ->
            page.searchStoresText 'very', ->
              page.clickDoSearchStores done
  it 'shows stores with flyers', (done) ->
    page.storesLength (l) ->
      l.should.equal 1
      done()
  it 'shows stores without flyers in a simple list', (done) ->
    page.storesWithoutFlyersLength (l) ->
      l.should.equal 1
      done()
  it 'links picture to store 1', (done) ->
    page.storeLink store3._id, (href) ->
      href.endsWith(store3.slug).should.be.true
      done()
