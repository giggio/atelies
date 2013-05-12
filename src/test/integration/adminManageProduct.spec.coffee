require './support/_specHelper'
Store     = require '../../models/store'
Product   = require '../../models/product'
User      = require '../../models/user'

describe 'Admin Manage Product page', ->
  page = product = store = userSeller = browser = page = null
  before (done) ->
    cleanDB (error) ->
      return done error if error
      whenServerLoaded ->
        store = generator.store.a()
        store.save()
        product = generator.product.a()
        product.save()
        userSeller = generator.user.c()
        userSeller.stores.push store
        userSeller.save()
        done()
  after -> browser.destroy() if browser?
  describe 'viewing product', (done) ->
    before (done) ->
      browser = newBrowser browser
      page = browser.adminManageProductPage
      browser.loginPage.navigateAndLoginWith userSeller, ->
        page.visit store.slug, product._id.toString(), done
    it 'shows product', ->
      aproduct = page.product()
      aproduct._id.should.equal product._id.toString()
      aproduct.name.should.equal product.name
      aproduct.price.should.equal product.price.toString()
      aproduct.slug.should.equal product.slug
      aproduct.picture.should.equal product.picture
      aproduct.tags.should.equal product.tags.join ', '
      aproduct.description.should.equal product.description
      aproduct.dimensions.height.should.equal product.dimensions.height
      aproduct.dimensions.width.should.equal product.dimensions.width
      aproduct.dimensions.depth.should.equal product.dimensions.depth
      aproduct.weight.should.equal product.weight
      aproduct.hasInventory.should.equal product.hasInventory
      aproduct.inventory.should.equal product.inventory

  xdescribe 'editing product', ->
    otherProduct = null
    before (done) ->
      otherProduct = generator.product.b()
      browser = newBrowser browser
      page = browser.adminManageProductPage
      browser.loginPage.navigateAndLoginWith userSeller, ->
        page.visit store.slug, product._id.toString(), ->
          page.setFieldsAs otherProduct
          page.clickUpdateProduct done
    it 'is at the store manage page', ->
      browser.location.href.should.equal "http://localhost:8000/admin#storeManage/#{product.storeSlug}"
    it 'updated the product', (done) ->
      storedProduct = Product.findById product._id, (err, product) ->
        return done err if err
        product.name.should.equal otherProduct.name
