require './support/_specHelper'
Store                       = require '../../app/models/store'
Product                     = require '../../app/models/product'
User                        = require '../../app/models/user'
AdminManageProductPage      = require './support/pages/adminManageProductPage'

describe 'Admin Create Product page', ->
  page = product = productNoShippingInfo = productNoShippingInfo2 = store = store2 = userSeller = null
  before (done) ->
    page = new AdminManageProductPage()
    cleanDB (error) ->
      return done error if error
      whenServerLoaded ->
        product = generator.product.a()
        productNoShippingInfo = product.toJSON()
        productNoShippingInfo2 = generator.product.b().toJSON()
        delete productNoShippingInfo.shipping
        delete productNoShippingInfo2.shipping
        store = generator.store.a()
        store.save()
        store2 = generator.store.b()
        store2.save()
        userSeller = generator.user.c()
        userSeller.stores.push store, store2
        userSeller.save()
        done()

  describe "can't create invalid product", ->
    before (done) ->
      page.loginFor userSeller._id, ->
        page.visit store.slug, ->
          page.setFieldsAs {name:'', price:'', dimensions: {height:'dd', width: 'ee', depth:'ff'}, weight: 'gg', shipping: { dimensions: {height:'nn', width: 'oo', depth:'pp'}, weight:'mm'}, inventory: 'hh'}, ->
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
        errorMsgs.height.should.equal 'A altura deve ser um número.'
        errorMsgs.width.should.equal 'A largura deve ser um número.'
        errorMsgs.depth.should.equal 'A profundidade deve ser um número.'
        errorMsgs.weight.should.equal 'O peso deve ser um número.'
        errorMsgs.shippingHeight.should.equal 'A altura deve ser um número entre 2 e 105.'
        errorMsgs.shippingWidth.should.equal 'A largura deve ser um número entre 11 e 105.'
        errorMsgs.shippingDepth.should.equal 'A profundidade deve ser um número entre 16 e 105.'
        errorMsgs.shippingWeight.should.equal 'O peso deve ser um número entre 0 e 30.'
        errorMsgs.inventory.should.equal 'O estoque deve ser um número.'
        done()

  describe 'new product on store with auto calculated shipping demands shipping info', ->
    before (done) ->
      page.loginFor userSeller._id, ->
        page.visit store.slug, ->
          page.setFieldsAs productNoShippingInfo, ->
            page.clickUpdateProduct -> waitSeconds 1, done #hasToWaitForElementsToRerender
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
        errorMsgs.shippingHeight.should.equal 'A altura de postagem é obrigatória.'
        errorMsgs.shippingWidth.should.equal 'A largura de postagem é obrigatória.'
        errorMsgs.shippingDepth.should.equal 'A profundidade de postagem é obrigatória.'
        errorMsgs.shippingWeight.should.equal 'O peso de postagem é obrigatório.'
        done()

  describe 'a product which states it has inventory should inform how many items it has on inventory when creating the product', ->
    before (done) ->
      productNoInventory = generator.product.a()
      productNoInventory.inventory = ''
      page.loginFor userSeller._id, ->
        page.visit store.slug, ->
          page.setFieldsAs productNoInventory, ->
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
        errorMsgs.inventory.should.equal 'O estoque é obrigatório quando o produto terá estoque.'
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

  describe 'create product with no shipping info on a store that does not have auto calculated shipping', ->
    before (done) ->
      page.loginFor userSeller._id, ->
        page.visit store2.slug, ->
          page.setFieldsAs productNoShippingInfo2, ->
            page.clickUpdateProduct done
    it 'is at the store manage page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/admin#store/#{store2.slug}"
        done()
    it 'created the product', (done) ->
      Product.find name: productNoShippingInfo2.name, (err, productsOnDb) ->
        return done err if err
        productsOnDb.should.have.length 1
        productOnDb = productsOnDb[0]
        productOnDb.name.should.equal productNoShippingInfo2.name
        productOnDb.price.should.equal productNoShippingInfo2.price
        productOnDb.tags.should.be.like productNoShippingInfo2.tags
        productOnDb.description.should.equal productNoShippingInfo2.description
        productOnDb.dimensions.height.should.equal productNoShippingInfo2.dimensions.height
        productOnDb.dimensions.width.should.equal productNoShippingInfo2.dimensions.width
        productOnDb.dimensions.depth.should.equal productNoShippingInfo2.dimensions.depth
        productOnDb.weight.should.equal productNoShippingInfo2.weight
        expect(productOnDb.shipping.dimensions.height).to.be.undefined
        expect(productOnDb.shipping.dimensions.width).to.be.undefined
        expect(productOnDb.shipping.dimensions.depth).to.be.undefined
        expect(productOnDb.shipping.weight).to.be.undefined
        productOnDb.hasInventory.should.equal productNoShippingInfo2.hasInventory
        productOnDb.inventory.should.equal productNoShippingInfo2.inventory
        done()
