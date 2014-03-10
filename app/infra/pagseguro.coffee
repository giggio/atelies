pagseguro       = require 'pagseguro'
request         = require 'request'
parseXml        = require('xml2js').parseString
module.exports = class PagSeguro
  getSalestatusFromPagseguroNotificationId: (notificationId, email, token, cb) ->
    url = "https://ws.pagseguro.uol.com.br/v2/transactions/notifications/#{notificationId}?email=#{email}&token=#{token}"
    request url, (err, response, body) ->
      return cb err if err?
      if response.statusCode isnt 200
        return parseXml body, {explicitArray: false}, (err, errorResult) ->
          return cb err if err?
          errorMsg = errorResult.errors.error.message
          cb new Error "Not a 200 status code response. Error: #{errorMsg}"
      parseXml body, (err, psTransaction) ->
        return cb err if err?
        orderId = psTransaction.transaction.reference
        saleStatus = switch psTransaction.transaction.status
          when 1 then 'waitingPayment'
          when 2 then 'waitingAnalysis'
          when 3 then 'paid'
          when 4 then 'available'
          when 5 then 'disputed'
          when 6 then 'returned'
          when 7 then 'canceled'
        cb null, orderId, saleStatus

  getOrderIdFromPagseguroTransactionId: (transactionId, email, token, cb) ->
    url = "https://ws.pagseguro.uol.com.br/v2/transactions/#{transactionId}?email=#{email}&token=#{token}"
    request url, (err, response, body) ->
      return cb err if err?
      if response.statusCode isnt 200
        return parseXml body, {explicitArray: false}, (err, errorResult) ->
          return cb new Error "Not a 200 status code response. Error parsing xml, body was #{body}, error was #{JSON.stringify(err)}." if err?
          errorMsg = errorResult.errors.error.message
          cb new Error "Not a 200 status code response. Error: #{errorMsg}"
      parseXml body, (err, psTransaction) ->
        return cb err if err?
        orderId = psTransaction.transaction.reference
        cb null, orderId

  sendToPagseguro: (store, order, user, cb) ->
    pag = new pagseguro store.pmtGateways.pagseguro.email, store.pmtGateways.pagseguro.token
    pag.currency 'BRL'
    pag.reference order._id.toString()
    for item, i in order.items
      pagItem =
        id: i + 1
        description: item.name
        amount: item.price.toFixed 2
        quantity: item.quantity
      pag.addItem pagItem
    if order.shippingCost > 0
      pag.addItem
        id: order.items.length
        description: "Frete"
        amount: order.shippingCost.toFixed 2
        quantity: 1
    pag.buyer
      name: user.name
      email: user.email
    pag.send (err, pagseguroResult) ->
      return cb err if err?
      return cb errorMsg: 'Loja não autorizada no PagSeguro' if pagseguroResult is 'Unauthorized'
      parseXml pagseguroResult, (err, pagseguroResult) ->
        return cb err if err?
        return cb pagseguroResult.errors if pagseguroResult.errors?
        cb null, pagseguroResult.checkout.code

  redirectUrl: (pagseguroCode) -> "https://pagseguro.uol.com.br/v2/checkout/payment.html?code=#{pagseguroCode}"
