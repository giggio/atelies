$ = require 'jquery'
Page = require './page'

module.exports = class AdminHomePage extends Page
  visit: (storeSlug, productSlug, options, cb) -> super "admin#manageProduct/#{storeSlug}/#{productSlug}", options, cb
  product: =>
    el = @browser.query('#product')
    id = $('td:first-child', row).text()
    product =
      id: id
      name: $("#name", el).val()
      price: $("#price", el).val()
      slug: $("#slug", el).text()
      picture: $("#picture", el).val()
    product
