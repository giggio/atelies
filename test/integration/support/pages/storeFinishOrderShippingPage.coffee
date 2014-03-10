Page          = require './seleniumPage'
async         = require 'async'
Q             = require 'q'
_             = require 'underscore'

module.exports = class StoreCartPage extends Page
  visit: (storeSlug) -> super "#{storeSlug}/finishOrder/shipping"
  address: ->
    @waitForSelectorClickable '#goBackToCart'
    .then => waitMilliseconds 500 #small wait necessary so we dont get a stale element exception
    .then =>
      Q.all [
        @getText("#deliveryAddress #street").then (t) -> street:t
        @getText("#deliveryAddress #street2").then (t) -> street2:t
        @getText("#deliveryAddress #city").then (t) -> city:t
        @getText("#deliveryAddress #state").then (t) -> state:t
        @getText("#deliveryAddress #zip").then (t) -> zip:t
      ]
    .then (vals) -> vals.reduce ((o, v) -> _.extend o, v), {}
  clickContinue: @::pressButton.partial '#finishOrderShipping'
  clickSedexOption: ->
    @waitForSelector '#shippingOptions_sedex'
    .then => @click '#shippingOptions_sedex'
  shippingInfo: ->
    @waitForSelector '#shippingInfo'
    .then =>
      @findElementsIn '#shippingInfo', 'input[type="radio"]'
      .then (els) =>
        Q.all els.map (el) =>
          Q.all [
            @getValue el
            @getParent(el).then (parent) => @getText parent
          ]
          .spread (value, text) -> value:value, text:text
  finishOrderButtonIsEnabled: @::getIsEnabled.partial '#finishOrderShipping'
  manualShippingCalculationMessage: @::getTextIfExists.partial '#manualShippingCalculationMessage'
  shippingInfoExists: @::hasElement.partial '#shippingInfo'
