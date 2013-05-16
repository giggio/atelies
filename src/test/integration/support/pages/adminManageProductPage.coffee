$ = require 'jquery'
Page = require './page'

module.exports = class AdminHomePage extends Page
  visit: (storeSlug, productId, options, cb) -> super "admin#manageProduct/#{storeSlug}/#{productId}", options, cb
  product: =>
    el = @browser.query('#editProduct')
    id = $('#_id', el).text()
    product =
      _id: id
      name: $("#name", el).val()
      price: $("#price", el).val()
      slug: $("#slug", el).text()
      picture: $("#picture", el).val()
      tags: $("#tags", el).val()
      description: $("#description", el).val()
      dimensions:
        height: parseInt $("#height", el).val()
        width: parseInt $("#width", el).val()
        depth: parseInt $("#depth", el).val()
      weight: parseInt $("#weight", el).val()
      hasInventory: $("#hasInventory", el).prop('checked')
      inventory: parseInt $("#inventory", el).val()
    product
  setFieldsAs: (product, cb) =>
    @browser.fill "#name", product.name
    @browser.fill "#price", product.price
    @browser.fill "#picture", product.picture
    @browser.fill "#tags", product.tags?.join ","
    @browser.fill "#description", product.description
    @browser.fill "#height", product.dimensions?.height
    @browser.fill "#width", product.dimensions?.width
    @browser.fill "#depth", product.dimensions?.depth
    @browser.fill "#weight", product.weight
    if product.hasInventory then @browser.check "#hasInventory" else @browser.uncheck '#hasInventory'
    @browser.fill "#inventory", product.inventory
    #@browser.fire '#name', 'change', cb #doesnt work... :(
    @browser.evaluate "$('#editProduct #name,#price,#picture,#tags,#description,#height,#width,#depth,#weight,#hasInventory,#inventory').change()"
    @browser.wait (e, browser) -> cb()
  clickUpdateProduct: (cb) => @browser.pressButton "#updateProduct", cb
  errorMessageFor: (field) ->
    @browser.text("##{field} ~ .tooltip .tooltip-inner")
