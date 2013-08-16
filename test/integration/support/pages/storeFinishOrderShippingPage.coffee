Page          = require './seleniumPage'
async         = require 'async'

module.exports = class StoreCartPage extends Page
  visit: (storeSlug, cb) => super "#{storeSlug}#finishOrder/shipping", cb
  address: (cb) ->
    @waitForSelectorClickable '#deliveryAddress #street', =>
      address = {}
      actions = [
        (cb) => @getText "#deliveryAddress #street", (t) -> address.street = t;cb()
        (cb) => @getText "#deliveryAddress #street2", (t) -> address.street2 = t;cb()
        (cb) => @getText "#deliveryAddress #city", (t) -> address.city = t;cb()
        (cb) => @getText "#deliveryAddress #state", (t) -> address.state = t;cb()
        (cb) => @getText "#deliveryAddress #zip", (t) -> address.zip = t;cb()
      ]
      async.parallel actions, ->
        #print address
        cb address
  clickContinue: @::pressButton.partial '#finishOrderShipping'
  clickSedexOption: (cb) ->
    @waitForSelector '#shippingOptions_sedex', =>
      @pressButton '#shippingOptions_sedex', cb
  shippingInfo: (cb) ->
    @waitForSelector '#shippingInfo' , =>
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
  finishOrderButtonIsEnabled: @::getIsEnabled.partial '#finishOrderShipping'
  manualShippingCalculationMessage: @::getTextIfExists.partial '#manualShippingCalculationMessage'
  shippingInfoExists: @::hasElement.partial '#shippingInfo'
