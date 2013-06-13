require './support/_specHelper'
Store                 = require '../../app/models/store'
Product               = require '../../app/models/product'
StoreProductPage      = require './support/pages/storeProductPage'
page                  = new StoreProductPage()

describe 'Store product page', ->
  after (done) -> page.closeBrowser done
  describe 'regular product', ->
    store = product1 = null
    before (done) ->
      cleanDB (error) ->
        return done error if error
        store = generator.store.a()
        store.save()
        product1 = generator.product.a()
        product1.save()
        whenServerLoaded ->
          page.visit "store_1", "name_1", done
    it 'should show the product info', (done) ->
      page.product (product) ->
        product.name.should.equal product1.name
        product.price.should.equal product1.price.toString()
        product.tags.should.be.like ['abc', 'def']
        product.description.should.equal product1.description
        product.height.should.equal product1.dimensions.height.toString()
        product.width.should.equal product1.dimensions.width.toString()
        product.depth.should.equal product1.dimensions.depth.toString()
        product.weight.should.equal product1.weight.toString()
        product.inventory.should.equal '30 itens'
        product.storeName.should.equal store.name
        product.storePhoneNumber.should.equal store.phoneNumber
        product.storeCity.should.equal store.city
        product.storeState.should.equal store.state
        product.storeOtherUrl.should.equal store.otherUrl
        product.banner.should.equal store.banner
        product.picture.should.equal product1.picture
        page.storeNameHeaderExists (itDoes) ->
          itDoes.should.be.false
          done()
  describe 'store without banner', ->
    store = product1 = null
    before (done) ->
      cleanDB (error) ->
        return done error if error
        store = generator.store.b()
        store.save()
        product1 = generator.product.c()
        product1.save()
        whenServerLoaded ->
          page.visit "store_2", "name_3", done
    it 'does not show the store banner', (done) ->
      page.storeBannerExists (itDoes) -> itDoes.should.be.false;done()
    it 'shows store name header', (done) ->
      page.storeNameHeader (header) ->
        header.should.equal store.name
        done()
