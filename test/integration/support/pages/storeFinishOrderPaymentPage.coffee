Page          = require './seleniumPage'
Q             = require 'q'

module.exports = class StoreFinishOrderPaymentPage extends Page
  visit: (storeSlug) => super "#{storeSlug}/finishOrder/payment"
  clickSelectDirectPayment: ->
    @waitForSelector '#directSell'
    .then => @click '#directSell'
  clickSelectPaymentType: @::pressButton.partial '#selectPaymentType'
  paymentTypes: ->
    @findElementsIn '#paymentTypesHolder', 'input[type="radio"]'
    .then (els) =>
      Q.all els.map (el) =>
        Q.all [
          @getValue el
          @getIsChecked el
        ]
        .spread (value, selected) -> value:value, selected:selected
