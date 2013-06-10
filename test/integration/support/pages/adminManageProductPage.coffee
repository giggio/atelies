$             = require 'jquery'
Page          = require './seleniumPage'
webdriver     = require 'selenium-webdriver'

module.exports = class AdminManageProductPage extends Page
  visit: (storeSlug, productId) ->
    if typeof productId is 'string'
      super "admin#manageProduct/#{storeSlug}/#{productId}"
    else
      super "admin#createProduct/#{storeSlug}"
       
  product: (cb) ->
    product = {}
    flow = webdriver.promise.createFlow (f) =>
      f.execute => @getText "#editProduct #_id", (text) -> product._id = text
      f.execute => @getValue "#editProduct #name", (text) -> product.name = text
      f.execute => @getValue "#editProduct #price", (text) -> product.price = text
      f.execute => @getText "#editProduct #slug", (text) -> product.slug = text
      f.execute => @getValue "#editProduct #picture", (text) -> product.picture = text
      f.execute => @getValue "#editProduct #tags", (text) -> product.tags = text
      f.execute => @getValue "#editProduct #description", (text) -> product.description = text
      f.execute => @getValue "#editProduct #height", (text) -> product.height = parseInt text
      f.execute => @getValue "#editProduct #width", (text) -> product.width = parseInt text
      f.execute => @getValue "#editProduct #depth", (text) -> product.depth = parseInt text
      f.execute => @getValue "#editProduct #weight", (text) -> product.weight = parseInt text
      f.execute => @getIsChecked "#editProduct #hasInventory", (itIs) -> product.hasInventory = itIs
      f.execute => @getValue "#editProduct #inventory", (text) -> product.inventory = parseInt text
    flow.then (-> cb(product)), cb
    #@doInParallel [
      #( (done) -> @getText "#editProduct #_id", (t) -> product._id = t;done()),
    #], (-> cb(product))
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
  clickConfirmDeleteProduct: (cb) =>
    btn = @findElement "#confirmDeleteProduct"
    @driver.wait (-> btn.isDisplayed().then((itIs) -> itIs)), 1000
    @pressButton "#confirmDeleteProduct", cb
