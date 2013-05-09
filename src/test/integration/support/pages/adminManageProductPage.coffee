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
        height: $("#height", el).val()
        width: $("#width", el).val()
        depth: $("#depth", el).val()
      weight: $("#weight", el).val()
      hasInventory: $("#hasInventory", el).prop('checked')
      inventory: $("#inventory", el).val()
    product
