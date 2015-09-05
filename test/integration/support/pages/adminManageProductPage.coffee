$             = require 'jquery'
Page          = require './seleniumPage'

module.exports = class AdminManageProductPage extends Page
  visit: (storeSlug, productId) ->
    if typeof productId is 'string'
      super "admin/manageProduct/#{storeSlug}/#{productId}"
    else
      super "admin/createProduct/#{storeSlug}"
       
  product: ->
    product =
      dimensions: {}
      shipping: dimensions: {}
    @parallel [
      => @getText("#editProduct #_id").then (text) -> product._id = text
      => @getValue("#editProduct #name").then (text) -> product.name = text
      => @getValue("#editProduct #price").then (text) -> product.price = text
      => @getText("#editProduct #slug").then (text) -> product.slug = text
      => @getSrc("#editProduct #showPicture").then (text) -> product.picture = text
      => @getValue("#editProduct #tags").then (text) -> product.tags = text
      => @getValue("#editProduct #description").then (text) -> product.description = text
      => @getValue("#editProduct #height").then (text) -> product.dimensions.height = parseInt text
      => @getValue("#editProduct #width").then (text) -> product.dimensions.width = parseInt text
      => @getValue("#editProduct #depth").then (text) -> product.dimensions.depth = parseInt text
      => @getValue("#editProduct #weight").then (text) -> product.weight = parseFloat text
      => @getIsChecked("#editProduct #shippingDoesApply").then (itIs) -> product.shipping.applies = itIs
      => @getIsChecked("#editProduct #shippingCharge").then (itIs) -> product.shipping.charge = itIs
      => @getValue("#editProduct #shippingHeight").then (text) -> product.shipping.dimensions.height = parseInt text
      => @getValue("#editProduct #shippingWidth").then (text) -> product.shipping.dimensions.width = parseInt text
      => @getValue("#editProduct #shippingDepth").then (text) -> product.shipping.dimensions.depth = parseInt text
      => @getValue("#editProduct #shippingWeight").then (text) -> product.shipping.weight = parseFloat text
      => @getIsChecked("#editProduct #hasInventory").then (itIs) -> product.hasInventory = itIs
      => @getValue("#editProduct #inventory").then (text) -> product.inventory = parseInt text
    ]
    .then -> product
  setFieldsAs: (product) =>
    @type "#name", product.name
    .then => @type "#price", product.price
    .then => @typeWithJS "#tags", product.tags?.join ","
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
  clickUpdateProduct: @::pressButtonAndWait.partial "#editProduct #updateProduct"
  clickDeleteProduct: @::pressButtonAndWait.partial "#deleteProduct"
  clickConfirmDeleteProduct: @::eval.partial "$('#confirmDeleteProduct').click()"
  setCategories: @::typeWithJS.partial "#categories"
  setPictureFile: @::uploadFile.partial '#picture'
