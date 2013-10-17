Page          = require './seleniumPage'

module.exports = class StoreFinishOrderPaymentPage extends Page
  visit: (storeSlug, cb) => super "#{storeSlug}/finishOrder/summary", cb
  summaryOfSale: (cb) ->
    summary = address:{}
    @parallel [
      => @getText "#shippingCost", (t) -> summary.shippingCost = t
      => @getText "#productsInfo", (t) -> summary.productsInfo = t
      => @getText "#totalProductsPrice", (t) -> summary.totalProductsPrice = t
      => @getText "#totalSaleAmount", (t) -> summary.totalSaleAmount = t
      => @getText "#street", (t) -> summary.address.street = t
      => @getText "#street2", (t) -> summary.address.street2 = t
      => @getText "#city", (t) -> summary.address.city = t
      => @getText "#state", (t) -> summary.address.state = t
      => @getText "#zip", (t) -> summary.address.zip = t
    ], (-> cb(summary))
  clickCompleteOrder: @::pressButtonAndWait.partial '#finishOrder'
