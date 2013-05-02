$ = require 'jquery'
module.exports = class AdminHomePage
  constructor: (@browser) ->
  visit: (cb) => @browser.visit "http://localhost:8000/admin", cb
  createStoreText: => @browser.query("#createStore").value
  rows: => @browser.query('#stores tbody')?.children
  storesQuantity: =>
    rows = @rows()
    if rows? then rows.length else 0
  stores: =>
    rows = @rows()
    stores = []
    for row in rows
      stores.push url: $('a', row).attr 'href'
    stores
