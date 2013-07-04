Page          = require './seleniumPage'

module.exports = class StoreFinishOrderPaymentPage extends Page
  visit: (storeSlug, cb) => super "#{storeSlug}#finishOrder/payment", cb
  clickSelectPaymentType: @::pressButton.partial '#selectPaymentType'
