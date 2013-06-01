$ = require 'jquery'
Page = require './page'

module.exports = class AdminHomePage extends Page
  visit: (storeSlug, options, cb) -> super "admin#store/#{storeSlug}", options, cb
  storeName: => @browser.text("#name")
  rows: => @browser.queryAll('#products .product')
  productsQuantity: =>
    rows = @rows()
    if rows? then rows.length else 0
  products: =>
    rows = @rows()
    products = []
    for row in rows
      id = $(row).attr 'data-id'
      products.push id: id, picture: $('img', row).attr('src'), name: $(".name", row).text(), manageLink: $(".link", row).attr('href')
    products
  createProductLink: =>
    @browser.query('#createProduct')
