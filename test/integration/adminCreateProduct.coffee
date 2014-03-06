require './support/_specHelper'
Store                       = require '../../app/models/store'
Product                     = require '../../app/models/product'
User                        = require '../../app/models/user'
AdminManageProductPage      = require './support/pages/adminManageProductPage'
AmazonFileUploader          = require '../../app/helpers/amazonFileUploader'
path                        = require "path"
Q                           = require 'q'

describe 'Admin Create Product page', ->
  page = product = productNoShippingInfo = productNoShippingInfo2 = store = userSeller = null
  before ->
    page = new AdminManageProductPage()
    cleanDB().then ->
      product = generator.product.a()
      productNoShippingInfo = product.toJSON()
      productNoShippingInfo.shipping.applies = true
      productNoShippingInfo.shipping.dimensions.height = ''
      productNoShippingInfo.shipping.dimensions.width = ''
      productNoShippingInfo.shipping.dimensions.depth = ''
      productNoShippingInfo.shipping.weight = ''
      productNoShippingInfo2 = generator.product.b().toJSON()
      productNoShippingInfo2.shipping.applies = false
      store = generator.store.a()
      store.save()
      userSeller = generator.user.c()
      userSeller.stores.push store
      userSeller.save()
    .then whenServerLoaded

  describe "can't create invalid product", ->
    before ->
      page.loginFor userSeller._id
      .then -> page.visit store.slug
      .then -> page.setFieldsAs name:'', price:'', dimensions: {height:'dd', width: 'ee', depth:'ff'}, weight: 'gg', shipping: { applies: true, dimensions: {height:'nn', width: 'oo', depth:'pp'}, weight:'mm'}, inventory: 'hh'
      .then -> page.clickUpdateProduct()
    it 'is at the product create page', -> page.currentUrl().should.become "http://localhost:8000/admin/createProduct/#{product.storeSlug}"
    it 'did not create the product', -> Q.ninvoke(Product, "find").then (products) -> products.should.be.empty
    it 'shows error messages', ->
      page.errorMessagesIn '#editProduct'
      .then (errorMsgs) ->
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

  describe 'a product which states it has inventory should inform how many items it has on inventory when creating the product', ->
    before ->
      productNoInventory = generator.product.a()
      productNoInventory.inventory = ''
      page.loginFor userSeller._id
      .then -> page.visit store.slug
      .then -> page.setFieldsAs productNoInventory
      .then page.clickUpdateProduct
    it 'is at the product create page', -> page.currentUrl (url) -> url.should.equal "http://localhost:8000/admin/createProduct/#{product.storeSlug}"
    it 'did not create the product', -> Product.find (err, products) -> products.should.be.empty
    it 'shows error messages', ->
      page.errorMessagesIn '#editProduct'
      .then (errorMsgs) -> errorMsgs.inventory.should.equal 'O estoque é obrigatório quando o produto terá estoque.'

  describe "can't create duplicate product", ->
    before ->
      existingProduct = generator.product.c()
      existingProduct.storeSlug = store.slug
      existingProduct.save()
      page.loginFor userSeller._id
      .then -> page.visit store.slug
      .then -> page.setFieldsAs existingProduct
      .then page.clickUpdateProduct
    it 'is at the product create page', -> page.currentUrl().should.become "http://localhost:8000/admin/createProduct/#{product.storeSlug}"
    it 'did not create the new product', ->
      Q.ninvoke Product, "find"
      .then (products) -> products.length.should.equal 1
    it 'shows error messages', -> page.getDialogMsg().should.become "Já há um produto nessa loja com esse nome. Cada produto da loja deve ter um nome direrente. Troque o nome e salve novamente."

  describe 'create product', ->
    before ->
      page.loginFor userSeller._id
      .then -> page.visit store.slug
      .then -> page.setFieldsAs product
      .then page.clickUpdateProduct
    it 'is at the store manage page', -> page.currentUrl (url) -> url.should.equal "http://localhost:8000/admin/store/#{product.storeSlug}"
    it 'created the product', ->
      Q.ninvoke Product, "find", name: product.name
      .then (productsOnDb) ->
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
        productOnDb.shipping.applies.should.equal product.shipping.applies
        productOnDb.shipping.charge.should.equal product.shipping.charge
        productOnDb.shipping.dimensions.height.should.equal product.shipping.dimensions.height
        productOnDb.shipping.dimensions.width.should.equal product.shipping.dimensions.width
        productOnDb.shipping.dimensions.depth.should.equal product.shipping.dimensions.depth
        productOnDb.shipping.weight.should.equal product.shipping.weight
        productOnDb.hasInventory.should.equal product.hasInventory
        productOnDb.inventory.should.equal product.inventory

  describe 'create a product with no shipping info if product is not posted', ->
    before ->
      page.loginFor userSeller._id
      .then -> page.visit store.slug
      .then -> page.setFieldsAs productNoShippingInfo2
      .then page.clickUpdateProduct
    it 'is at the store manage page', -> page.currentUrl().should.become "http://localhost:8000/admin/store/#{store.slug}"
    it 'created the product', ->
      Q.ninvoke Product, "find", name: productNoShippingInfo2.name
      .then (productsOnDb) ->
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
        expect(productOnDb.shipping.applies).to.equal false
        productOnDb.hasInventory.should.equal productNoShippingInfo2.hasInventory
        productOnDb.inventory.should.equal productNoShippingInfo2.inventory

  describe 'create a product with upload', ->
    uploadedRegexMatch = /^https:\/\/s3\.amazonaws\.com\/dryrun\/store_1\/products\/\d+\.png$/
    uploadedThumbRegexMatch = /^https:\/\/s3\.amazonaws\.com\/dryrun\/store_1\/products\/\d+_thumb150x150\.png$/
    product3 = null
    before ->
      AmazonFileUploader.filesUploaded.length = 0
      product3 = generator.product.e()
      product3.picture = null
      page.loginFor userSeller._id
      .then -> page.visit store.slug
      .then -> page.setFieldsAs product3
      .then ->
        filePath = path.join __dirname, 'support', 'images', '700x700.png'
        page.setPictureFile filePath
      .then page.clickUpdateProduct
    it 'is at the store manage page', -> page.currentUrl().should.become "http://localhost:8000/admin/store/#{product3.storeSlug}"
    it 'tried to upload the file and thumbnail', ->
      AmazonFileUploader.filesUploaded.length.should.equal 2
      AmazonFileUploader.filesUploaded[0].should.match uploadedRegexMatch
      AmazonFileUploader.filesUploaded[1].should.match uploadedThumbRegexMatch
    it 'created the file on the db with the file name correct', ->
      Q.ninvoke Product, "find", name: product3.name
      .then (productsOnDb) ->
        productsOnDb.should.have.length 1
        productOnDb = productsOnDb[0]
        productOnDb.picture.should.match uploadedRegexMatch
        productOnDb.name.should.equal product3.name
        productOnDb.price.should.equal product3.price
        productOnDb.tags.should.be.like product3.tags
        productOnDb.description.should.equal product3.description
        productOnDb.dimensions.height.should.equal product3.dimensions.height
        productOnDb.dimensions.width.should.equal product3.dimensions.width
        productOnDb.dimensions.depth.should.equal product3.dimensions.depth
        productOnDb.weight.should.equal product3.weight
        productOnDb.shipping.applies.should.equal product3.shipping.applies
        productOnDb.shipping.charge.should.equal product3.shipping.charge
        productOnDb.shipping.dimensions.height.should.equal product3.shipping.dimensions.height
        productOnDb.shipping.dimensions.width.should.equal product3.shipping.dimensions.width
        productOnDb.shipping.dimensions.depth.should.equal product3.shipping.dimensions.depth
        productOnDb.shipping.weight.should.equal product3.shipping.weight
        productOnDb.hasInventory.should.equal product3.hasInventory
        productOnDb.inventory.should.equal product3.inventory
