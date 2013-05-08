$ = require 'jquery'
Page = require './page'

module.exports = class AdminHomePage extends Page
  visit: (storeSlug, options, cb) -> super "admin#manageStore/#{storeSlug}", options, cb
  storeName: => @browser.text("#name")
  rows: => @browser.query('#products tbody')?.children
  productsQuantity: =>
    rows = @rows()
    if rows? then rows.length else 0
  products: =>
    rows = @rows()
    products = []
    for row in rows
      products.push picture: $('img', row).attr 'src', name: $('.productName', row).text()
    products
