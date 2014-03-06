Page          = require './seleniumPage'
Q             = require 'q'
_             = require 'underscore'

module.exports = class StoreFinishOrderPaymentPage extends Page
  visit: (storeSlug) => super "#{storeSlug}/finishOrder/summary"
  summaryOfSale: ->
    Q.all [
      @getText("#shippingCost").then (t) -> shippingCost: t
      @getText("#productsInfo").then (t) -> productsInfo: t
      @getText("#totalProductsPrice").then (t) -> totalProductsPrice: t
      @getText("#totalSaleAmount").then (t) -> totalSaleAmount: t
    ]
    .then (vals) -> vals.reduce ((o, v) -> _.extend o, v), address:{}
    .then (summary) =>
      Q.all [
        @getText("#street").then (t) -> street: t
        @getText("#street2").then (t) -> street2: t
        @getText("#city").then (t) -> city: t
        @getText("#state").then (t) -> state: t
        @getText("#zip").then (t) -> zip: t
      ]
      .then (vals) -> vals.reduce ((o, v) -> _.extend o, v), summary.address
      .then -> summary
  clickCompleteOrder: @::pressButtonAndWait.partial '#finishOrder'
