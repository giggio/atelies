Page    = require './page'

module.exports = class StoreCartPage extends Page
  visit: (storeSlug, options, cb) => super "#{storeSlug}#cart", options, cb
  quantity: => parseInt @browser.query('#cartItems > tbody > tr > td:nth-child(3) input').value
  name: => @browser.text('#cartItems > tbody > tr > td:nth-child(2)')
  id: => @browser.text('#cartItems > tbody > tr > td:first-child')
  rows: => @browser.query('#cartItems tbody')?.children
  itemsQuantity: =>
    rows = @rows()
    if rows? then rows.length else 0
  #removeItem: (product, cb) => @browser.pressButtonWait "#product#{product._id} .remove", cb
  removeItem: (product, cb) =>
    @browser.evaluate "$(\".remove\", $(\"span:contains('#{product._id}')\").parent().parent()).click()"
    @browser.wait cb
  updateQuantity: (product, quantity, cb) =>
    @browser.evaluate "$(\".quantity\", $(\"span:contains('#{product._id}')\").parent().parent()).val('#{quantity}').change()"
    @browser.evaluate "$(\".updateQuantity\", $(\"span:contains('#{product._id}')\").parent().parent()).click()"
    @browser.wait cb
  clearCart: (cb) => @browser.pressButtonWait "#clearCart", cb
