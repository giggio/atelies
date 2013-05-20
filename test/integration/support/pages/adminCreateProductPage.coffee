$ = require 'jquery'
Page = require './page'

module.exports = class AdminCreateProductPage extends Page
  visit: (storeSlug, options, cb) -> super "admin#createProduct/#{storeSlug}", options, cb
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
    @browser.evaluate "$('#editProduct #name,#price,#picture,#tags,#description,#height,#width,#depth,#weight,#hasInventory,#inventory').change()"
    @browser.wait (e, browser) -> cb()
  clickCreateProduct: (cb) => @browser.pressButton "#createProduct", cb
