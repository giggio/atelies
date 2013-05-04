Page    = require './page'

module.exports = class StoreProductPage extends Page
  visit: (storeSlug, productSlug, options, cb) => super "#{storeSlug}##{productSlug}", options, cb
  purchaseItem: (cb) => @browser.pressButtonWait "#purchaseItem", cb
