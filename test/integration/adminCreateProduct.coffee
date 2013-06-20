require './support/_specHelper'
Store                       = require '../../app/models/store'
Product                     = require '../../app/models/product'
User                        = require '../../app/models/user'
AdminManageProductPage      = require './support/pages/adminManageProductPage'

describe 'Admin Create Product page', ->
  page = product = store = userSeller = null
  before (done) ->
    page = new AdminManageProductPage()
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
  after (done) -> page.closeBrowser done

  describe 'cant create invalid product', ->
    before (done) ->
      page.loginFor userSeller._id, ->
        page.visit store.slug, ->
          page.setFieldsAs {name:'', price:'', picture: 'abc', height:'dd', width: 'ee', depth:'ff', weight: 'gg', inventory: 'hh'}, ->
            page.clickUpdateProduct done
    it 'is at the product create page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/admin#createProduct/#{product.storeSlug}"
        done()
    it 'did not create the product', (done) ->
      Product.find (err, products) ->
        return done err if err
        products.should.be.empty
        done()
    it 'shows error messages', (done) ->
      page.errorMessagesIn '#editProduct', (errorMsgs) ->
        errorMsgs.name.should.equal 'O nome é obrigatório.'
        errorMsgs.price.should.equal 'O preço é obrigatório.'
        errorMsgs.picture.should.equal 'A imagem deve ser uma url.'
        errorMsgs.height.should.equal 'A altura deve ser um número.'
        errorMsgs.width.should.equal 'A largura deve ser um número.'
        errorMsgs.depth.should.equal 'A profundidade deve ser um número.'
        errorMsgs.weight.should.equal 'O peso deve ser um número.'
        errorMsgs.shippingHeight.should.equal 'A altura deve ser um número.'
        errorMsgs.shippingWidth.should.equal 'A largura deve ser um número.'
        errorMsgs.shippingDepth.should.equal 'A profundidade deve ser um número.'
        errorMsgs.shippingWeight.should.equal 'O peso deve ser um número.'
        errorMsgs.inventory.should.equal 'O estoque deve ser um número.'
        done()

  describe 'create product', ->
    before (done) ->
      page.loginFor userSeller._id, ->
        page.visit store.slug, ->
          page.setFieldsAs product, ->
            page.clickUpdateProduct done
    it 'is at the store manage page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/admin#store/#{product.storeSlug}"
        done()
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
        productOnDb.shipping.dimensions.height.should.equal product.shipping.dimensions.height
        productOnDb.shipping.dimensions.width.should.equal product.shipping.dimensions.width
        productOnDb.shipping.dimensions.depth.should.equal product.shipping.dimensions.depth
        productOnDb.shipping.weight.should.equal product.shipping.weight
        productOnDb.hasInventory.should.equal product.hasInventory
        productOnDb.inventory.should.equal product.inventory
        done()
