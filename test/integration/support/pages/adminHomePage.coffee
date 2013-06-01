$ = require 'jquery'
Page = require './page'

module.exports = class AdminHomePage extends Page
  url: 'admin'
  createStoreText: => @browser.query("#createStore").value
  rows: => @browser.queryAll('#stores .store')
  storesQuantity: =>
    rows = @rows()
    if rows? then rows.length else 0
  stores: =>
    rows = @rows()
    stores = []
    for row in rows
      stores.push url: $('a', row).attr 'href'
    stores
