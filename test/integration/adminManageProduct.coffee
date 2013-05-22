require './support/_specHelper'
Store     = require '../../app/models/store'
Product   = require '../../app/models/product'
User      = require '../../app/models/user'

describe 'Admin Manage Product page', ->
  page = product = product2 = store = userSeller = browser = page = null
  before (done) ->
    cleanDB (error) ->
      return done error if error
      whenServerLoaded ->
        store = generator.store.a()
        store.save()
        product = generator.product.a()
        product.save()
        product2 = generator.product.d()
        product2.save()
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

  describe 'cant update invalid product', ->
    before (done) ->
      browser = newBrowser browser
      page = browser.adminManageProductPage
      browser.loginPage.navigateAndLoginWith userSeller, ->
        page.visit store.slug, product._id.toString(), ->
          page.setFieldsAs {name:'', price:'', picture: 'abc', height:'dd', width: 'ee', depth:'ff', weight: 'gg', inventory: 'hh'}, ->
            page.clickUpdateProduct done
    it 'is at the product manage page', ->
      browser.location.href.should.equal "http://localhost:8000/admin#manageProduct/#{product.storeSlug}/#{product._id}"
    it 'did not update the product', (done) ->
      Product.findById product._id, (err, productOnDb) ->
        return done err if err
        productOnDb.name.should.equal product.name
        productOnDb.price.should.equal product.price
        productOnDb.picture.should.equal product.picture
        productOnDb.tags.should.be.like product.tags
        productOnDb.description.should.equal product.description
        productOnDb.dimensions.height.should.equal product.dimensions.height
        productOnDb.dimensions.width.should.equal product.dimensions.width
        productOnDb.dimensions.depth.should.equal product.dimensions.depth
        productOnDb.weight.should.equal product.weight
        productOnDb.hasInventory.should.equal product.hasInventory
        productOnDb.inventory.should.equal product.inventory
        done()
    it 'shows error messages', ->
      page.errorMessageFor('name').should.equal 'O nome é obrigatório.'
      page.errorMessageFor('price').should.equal 'O preço é obrigatório.'
      page.errorMessageFor('picture').should.equal 'A imagem deve ser uma url.'
      page.errorMessageFor('height').should.equal 'A altura deve ser um número.'
      page.errorMessageFor('width').should.equal 'A largura deve ser um número.'
      page.errorMessageFor('depth').should.equal 'A profundidade deve ser um número.'
      page.errorMessageFor('weight').should.equal 'O peso deve ser um número.'
      page.errorMessageFor('inventory').should.equal 'O estoque deve ser um número.'

  describe 'editing product', ->
    otherProduct = null
    before (done) ->
      otherProduct = generator.product.b()
      browser = newBrowser browser
      page = browser.adminManageProductPage
      browser.loginPage.navigateAndLoginWith userSeller, ->
        page.visit store.slug, product._id.toString(), ->
          page.setFieldsAs otherProduct, ->
            page.clickUpdateProduct done
    it 'is at the store manage page', ->
      browser.location.href.should.equal "http://localhost:8000/admin#manageStore/#{product.storeSlug}"
    it 'updated the product', (done) ->
      Product.findById product._id, (err, productOnDb) ->
        return done err if err
        productOnDb.name.should.equal otherProduct.name
        productOnDb.price.should.equal otherProduct.price
        productOnDb.picture.should.equal otherProduct.picture
        productOnDb.tags.should.be.like otherProduct.tags
        productOnDb.description.should.equal otherProduct.description
        productOnDb.dimensions.height.should.equal otherProduct.dimensions.height
        productOnDb.dimensions.width.should.equal otherProduct.dimensions.width
        productOnDb.dimensions.depth.should.equal otherProduct.dimensions.depth
        productOnDb.weight.should.equal otherProduct.weight
        productOnDb.hasInventory.should.equal otherProduct.hasInventory
        productOnDb.inventory.should.equal otherProduct.inventory
        done()

  xdescribe 'deleting product', ->
    otherProduct = null
    before (done) ->
      browser = newBrowser browser
      page = browser.adminManageProductPage
      browser.loginPage.navigateAndLoginWith userSeller, ->
        page.visit store.slug, product2._id.toString(), ->
          page.clickDeleteProduct ->
            page.clickConfirmDeleteProduct done
    it 'is at the store manage page', ->
      browser.location.href.should.equal "http://localhost:8000/admin#manageStore/#{product2.storeSlug}"
    it 'deleted the product', (done) ->
      Product.findById product2._id, (err, productOnDb) ->
        return done err if err
        productOnDb.should.be.null
        done()
