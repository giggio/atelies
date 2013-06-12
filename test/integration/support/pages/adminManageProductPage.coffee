$             = require 'jquery'
Page          = require './seleniumPage'

module.exports = class AdminManageProductPage extends Page
  visit: (storeSlug, productId, cb) ->
    if typeof productId is 'string'
      super "admin#manageProduct/#{storeSlug}/#{productId}", cb
    else
      cb = productId
      super "admin#createProduct/#{storeSlug}", cb
       
  product: (cb) ->
    product = {}
    @parallel [
      => @getText "#editProduct #_id", (text) -> product._id = text
      => @getValue "#editProduct #name", (text) -> product.name = text
      => @getValue "#editProduct #price", (text) -> product.price = text
      => @getText "#editProduct #slug", (text) -> product.slug = text
      => @getValue "#editProduct #picture", (text) -> product.picture = text
      => @getValue "#editProduct #tags", (text) -> product.tags = text
      => @getValue "#editProduct #description", (text) -> product.description = text
      => @getValue "#editProduct #height", (text) -> product.height = parseInt text
      => @getValue "#editProduct #width", (text) -> product.width = parseInt text
      => @getValue "#editProduct #depth", (text) -> product.depth = parseInt text
      => @getValue "#editProduct #weight", (text) -> product.weight = parseInt text
      => @getIsChecked "#editProduct #hasInventory", (itIs) -> product.hasInventory = itIs
      => @getValue "#editProduct #inventory", (text) -> product.inventory = parseInt text
    ], (-> cb(product))
  setFieldsAs: (product, cb) =>
    @type "#name", product.name
    @type "#price", product.price
    @type "#picture", product.picture
    @type "#tags", product.tags?.join ","
    @type "#description", product.description
    @type "#height", product.dimensions?.height
    @type "#width", product.dimensions?.width
    @type "#depth", product.dimensions?.depth
    @type "#weight", product.weight
    if product.hasInventory then @check "#hasInventory" else @uncheck '#hasInventory'
    @type "#inventory", product.inventory
    cb()
  clickUpdateProduct: (cb) => @pressButton "#updateProduct", cb
  clickDeleteProduct: (cb) => @pressButton "#deleteProduct", cb
  clickConfirmDeleteProduct: (cb) => @eval "$('#confirmDeleteProduct').click()", cb
