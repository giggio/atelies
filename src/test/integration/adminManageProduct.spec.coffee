require './support/_specHelper'
Store     = require '../../models/store'
Product   = require '../../models/product'
User      = require '../../models/user'

describe 'Admin Manage Product page', ->
  page = product = store = userSeller = browser = null
  before (done) -> whenServerLoaded done
  after -> browser.destroy() if browser?
  describe 'viewing product', (done) ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        store = generator.store.a()
        store.save()
        product = generator.product.a()
        product.save()
        userSeller = generator.user.c()
        userSeller.stores.push store
        userSeller.save()
        browser = newBrowser browser
        page = browser.adminManageProductPage
        browser.loginPage.navigateAndLoginWith userSeller, ->
          page.visit store.slug, product._id.toString(), ->
            browser.reload done
    it 'shows product', ->
      product = page.product()
      product._id.should.equal product._id
      product.name.should.equal product.name
      product.price.should.equal product.price
      product.slug.should.equal product.slug
      product.picture.should.equal product.picture
      product.tags.should.equal product.tags
      product.description.should.equal product.description
      product.dimensions.should.equal product.dimensions
      product.weight.should.equal product.weight
      product.hasInventory.should.equal product.hasInventory
      product.inventory.should.equal product.inventory
