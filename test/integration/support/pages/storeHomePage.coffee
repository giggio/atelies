Page    = require './page'

module.exports = class StoreHomePage extends Page
  visit: (storeSlug, options, cb) => super "#{storeSlug}", options, cb
  products: -> @browser.queryAll('.storeContainer #products .product')
