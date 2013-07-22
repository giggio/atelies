Page          = require './seleniumPage'

module.exports = class StoreFinishOrderPaymentPage extends Page
  visit: (storeSlug, cb) => super "#{storeSlug}#finishOrder/payment", cb
  clickSelectDirectPayment: (cb) ->
    @waitForSelector '#directSell', =>
      @pressButton '#directSell', cb
  clickSelectPaymentType: @::pressButton.partial '#selectPaymentType'
  paymentTypes: (cb) ->
    options = []
    getData = []
    @findElementsIn '#paymentTypesHolder', 'input[type="radio"]', (els) =>
      for el in els
        do (el) =>
          option = {}
          options.push option
          getData.push => @getValue el, (t) => option.value = t
          getData.push => @getIsChecked el, (itIs) => option.selected = itIs
      @parallel getData, -> cb options
      undefined
