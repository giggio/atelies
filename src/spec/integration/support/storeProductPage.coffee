module.exports = class StoreProductPage
  constructor: (@browser) ->
  visit: (storeSlug, productSlug, cb) => @browser.visit "http://localhost:8000/#{storeSlug}##{productSlug}", cb
  purchaseItem: (cb) => @browser.pressButtonWait "#purchaseItem", cb
