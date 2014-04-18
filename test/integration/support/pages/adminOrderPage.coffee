Page          = require './seleniumPage'

module.exports = class AccountOrderPage extends Page
  visit: (_id) -> super "admin/orders/#{_id}"
  orderState: -> @getText '#orderState'
  changeStateTo: (newState) ->
    @click '#changeOrderStatus'
    .then => @selectWithValue '#changeState', newState
    .then => @click '#doChangeOrderStatus'
