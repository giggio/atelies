require './support/_specHelper'
Store     = require '../../models/store'
Product   = require '../../models/product'
User      = require '../../models/user'

describe 'Admin Create Product page', ->
  page = product = store = userSeller = browser = page = null
  before (done) ->
    cleanDB (error) ->
      return done error if error
      whenServerLoaded ->
        product = generator.product.a()
        store = generator.store.a()
        store.save()
        userSeller = generator.user.c()
        userSeller.stores.push store
        userSeller.save()
        done()
  after -> browser.destroy() if browser?

  describe 'cant create invalid product', ->
    before (done) ->
      browser = newBrowser browser
      page = browser.adminManageProductPage
      browser.loginPage.navigateAndLoginWith userSeller, ->
        page.visit store.slug, ->
          page.setFieldsAs {name:'', price:'', picture: 'abc', height:'dd', width: 'ee', depth:'ff', weight: 'gg', inventory: 'hh'}, ->
            page.clickUpdateProduct done
    it 'is at the product create page', ->
      browser.location.href.should.equal "http://localhost:8000/admin#createProduct/#{product.storeSlug}"
    it 'did not create the product', (done) ->
      Product.find (err, products) ->
        return done err if err
        products.should.be.empty
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

  describe 'create product', ->
    before (done) ->
      browser = newBrowser browser
      page = browser.adminManageProductPage
      browser.loginPage.navigateAndLoginWith userSeller, ->
        page.visit store.slug, ->
          page.setFieldsAs product, ->
            page.clickUpdateProduct done
    it 'is at the store manage page', ->
      browser.location.href.should.equal "http://localhost:8000/admin#manageStore/#{product.storeSlug}"
    it 'created the product', (done) ->
      Product.find (err, productsOnDb) ->
        return done err if err
        productsOnDb.should.have.length 1
        productOnDb = productsOnDb[0]
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
