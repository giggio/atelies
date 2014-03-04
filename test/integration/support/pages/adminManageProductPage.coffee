$             = require 'jquery'
Page          = require './seleniumPage'

module.exports = class AdminManageProductPage extends Page
  visit: (storeSlug, productId) ->
    if typeof productId is 'string'
      super "admin/manageProduct/#{storeSlug}/#{productId}"
    else
      super "admin/createProduct/#{storeSlug}"
       
  product: (cb) ->
    product =
      dimensions: {}
      shipping: dimensions: {}
    @parallel [
      => @getText "#editProduct #_id", (text) -> product._id = text
      => @getValue "#editProduct #name", (text) -> product.name = text
      => @getValue "#editProduct #price", (text) -> product.price = text
      => @getText "#editProduct #slug", (text) -> product.slug = text
      => @getSrc "#editProduct #showPicture", (text) -> product.picture = text
      => @getValue "#editProduct #tags", (text) -> product.tags = text
      => @getValue "#editProduct #description", (text) -> product.description = text
      => @getValue "#editProduct #height", (text) -> product.dimensions.height = parseInt text
      => @getValue "#editProduct #width", (text) -> product.dimensions.width = parseInt text
      => @getValue "#editProduct #depth", (text) -> product.dimensions.depth = parseInt text
      => @getValue "#editProduct #weight", (text) -> product.weight = parseFloat text
      => @getIsChecked "#editProduct #shippingDoesApply", (itIs) -> product.shipping.applies = itIs
      => @getIsChecked "#editProduct #shippingCharge", (itIs) -> product.shipping.charge = itIs
      => @getValue "#editProduct #shippingHeight", (text) -> product.shipping.dimensions.height = parseInt text
      => @getValue "#editProduct #shippingWidth", (text) -> product.shipping.dimensions.width = parseInt text
      => @getValue "#editProduct #shippingDepth", (text) -> product.shipping.dimensions.depth = parseInt text
      => @getValue "#editProduct #shippingWeight", (text) -> product.shipping.weight = parseFloat text
      => @getIsChecked "#editProduct #hasInventory", (itIs) -> product.hasInventory = itIs
      => @getValue "#editProduct #inventory", (text) -> product.inventory = parseInt text
    ], (-> cb(product))
  setFieldsAs: (product) =>
    @type "#name", product.name
    .then => @type "#price", product.price
    .then => @type "#tags", product.tags?.join ","
    .then => @type "#description", product.description
    .then => @type "#height", product.dimensions?.height
    .then => @type "#width", product.dimensions?.width
    .then => @type "#depth", product.dimensions?.depth
    .then => @type "#weight", product.weight
    .then =>
      if product.shipping?.applies
        (if product.shipping?.charge then @check "#shippingCharge" else @uncheck '#shippingCharge')
        .then => @type "#shippingHeight", product.shipping?.dimensions?.height
        .then => @type "#shippingWidth", product.shipping?.dimensions?.width
        .then => @type "#shippingDepth", product.shipping?.dimensions?.depth
        .then => @type "#shippingWeight", product.shipping?.weight
      else
        @click '#shippingDoesNotApply'
    .then => if product.hasInventory then @check "#hasInventory" else @uncheck '#hasInventory'
    .then => @type "#inventory", product.inventory
    .then => @eval "document.getElementById('inventory').blur()"
  clickUpdateProduct: (cb) => @pressButtonAndWait "#editProduct #updateProduct", cb
  clickDeleteProduct: (cb) => @pressButtonAndWait "#deleteProduct", cb
  clickConfirmDeleteProduct: (cb) => @eval "$('#confirmDeleteProduct').click()", cb
  setCategories: (categories) => @type "#categories", categories
  setPictureFile: @::uploadFile.partial '#picture'
