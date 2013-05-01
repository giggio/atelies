module.exports = class StoreCartPage
  constructor: (@browser) ->
  quantity: => parseInt @browser.query('#cartItems > tbody > tr > td:nth-child(3) .quantity').value
  name: => @browser.text('#cartItems > tbody > tr > td:nth-child(2)')
  id: => @browser.text('#cartItems > tbody > tr > td:first-child')
  rows: => @browser.query('#cartItems tbody')?.children
  itemsQuantity: =>
    rows = @rows()
    if rows? then rows.length else 0
  visit: (storeSlug, cb) => @browser.visit "http://localhost:8000/#{storeSlug}#cart", cb
  removeItem: (product, cb) => @browser.pressButtonWait "#product#{product._id} .remove", cb
  updateQuantity: (product, quantity, cb) => @browser.fill("#product#{product._id} .quantity", quantity.toString()).pressButton ".updateQuantity", cb
  clearCart: (cb) => @browser.pressButtonWait "#clearCart", cb
