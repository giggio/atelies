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
    product
