Page          = require './seleniumPage'

module.exports = class StoreCartPage extends Page
  visit: (storeSlug, cb) => super "#{storeSlug}#finishOrder/shipping", cb
  address: (cb) ->
    address = {}
    actions = [
      => @getText "#deliveryAddress #street", (t) -> address.street = t
      => @getText "#deliveryAddress #street2", (t) -> address.street2 = t
      => @getText "#deliveryAddress #city", (t) -> address.city = t
      => @getText "#deliveryAddress #state", (t) -> address.state = t
      => @getText "#deliveryAddress #zip", (t) -> address.zip = t
    ]
    @parallel actions, -> print address;cb address
  clickContinue: @::pressButton.partial '#finishOrder'
  clickSedexOption: (cb) ->
    @waitForSelector '#shippingOptions_sedex', =>
      @pressButton '#shippingOptions_sedex', cb
  shippingInfo: (cb) ->
    options = []
    getData = []
    @findElementsIn '#shippingInfo', 'input[type="radio"]', (els) =>
      for el in els
        do (el) =>
          option = {}
          options.push option
          getData.push => @getValue el, (t) => option.value = t
      @parallel getData, -> cb(options: options)
      undefined
  finishOrderButtonIsEnabled: @::getIsEnabled.partial '#finishOrder'
  manualShippingCalculationMessage: @::getTextIfExists.partial '#manualShippingCalculationMessage'
  shippingInfoExists: @::hasElement.partial '#shippingInfo'
