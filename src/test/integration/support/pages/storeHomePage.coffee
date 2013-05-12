Page    = require './page'

module.exports = class StoreHomePage extends Page
  visit: (storeSlug, options, cb) => super "#{storeSlug}", options, cb
