require './support/_specHelper'
Store     = require '../../app/models/store'
Product   = require '../../app/models/product'
User      = require '../../app/models/user'

describe 'Admin Show Store page', ->
  page = product1 = product2 = store = userSeller = browser = null
  before (done) -> whenServerLoaded done
  after -> browser.destroy() if browser?
  describe 'viewing store products', (done) ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        store = generator.store.a()
        store.save()
        product1 = generator.product.a()
        product1.save()
        product2 = generator.product.b()
        product2.save()
        userSeller = generator.user.c()
        userSeller.stores.push store
        userSeller.save()
        browser = newBrowser browser
        page = browser.adminStorePage
        browser.loginPage.navigateAndLoginWith userSeller, ->
          page.visit store.slug, done
    it 'shows store products', ->
      products = page.products()
      products.length.should.equal 2
      products[0].name.should.equal product1.name
      products[0].picture.should.equal product1.picture + "_thumb150x150"
    it 'shows store name', ->
      page.storeName().should.equal store.name
    it 'allows to create new product', ->
      page.createProductLink().href.endsWith("#createProduct/#{store.slug}").should.be.true
    it 'allows to edit products', ->
      products = page.products()
      products[0].manageLink.should.equal "#manageProduct/#{store.slug}/#{product1._id}"
      products[1].manageLink.should.equal "#manageProduct/#{store.slug}/#{product2._id}"
