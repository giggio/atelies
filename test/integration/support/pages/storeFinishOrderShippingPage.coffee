Page          = require './seleniumPage'

module.exports = class StoreCartPage extends Page
  visit: (storeSlug, cb) => super "#{storeSlug}#finishOrder/shipping", cb
  address: (cb) ->
    address = {}
    @parallel [
      => @getText "#deliveryAddress #street", (t) -> address.street = t
      => @getText "#deliveryAddress #street2", (t) -> address.street2 = t
      => @getText "#deliveryAddress #city", (t) -> address.city = t
      => @getText "#deliveryAddress #state", (t) -> address.state = t
      => @getText "#deliveryAddress #zip", (t) -> address.zip = t
    ], (-> cb(address))
  clickContinue: @::pressButton.partial '#finishOrder'
