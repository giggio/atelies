pagseguro       = require 'pagseguro'
Q               = require 'q'
request         = require 'request'
request         = Q.denodeify request
parseXml        = require('xml2js').parseString
parseXml        = Q.denodeify parseXml

module.exports = class PagSeguro
  getSalestatusFromPagseguroNotificationId: (notificationId, email, token) ->
    url = "https://ws.pagseguro.uol.com.br/v2/transactions/notifications/#{notificationId}?email=#{email}&token=#{token}"
    request url
    .then (response, body) ->
      if response.statusCode isnt 200
        parseXml body, explicitArray: false
        .then (errorResult) -> throw new Error "Not a 200 status code response. Error: #{errorResult.errors.error.message}"
      parseXml body
    .then (psTransaction) ->
      orderId = psTransaction.transaction.reference
      saleStatus = switch psTransaction.transaction.status
        when 1 then 'waitingPayment'
        when 2 then 'waitingAnalysis'
        when 3 then 'paid'
        when 4 then 'available'
        when 5 then 'disputed'
        when 6 then 'returned'
        when 7 then 'canceled'
      [orderId, saleStatus]

  getOrderIdFromPagseguroTransactionId: (transactionId, email, token) ->
    url = "https://ws.pagseguro.uol.com.br/v2/transactions/#{transactionId}?email=#{email}&token=#{token}"
    request url
    .then (response, body) ->
      if response.statusCode isnt 200
        parseXml body, explicitArray: false
        .catch (err) -> throw new Error "Not a 200 status code response. Error parsing xml, body was #{body}, error was #{JSON.stringify(err)}."
        .then (errorResult) -> throw new Error "Not a 200 status code response. Error: #{errorResult.errors.error.message}"
      parseXml body
    .then (psTransaction) ->
      orderId = psTransaction.transaction.reference
      orderId

  sendToPagseguro: (store, order, user) ->
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
    Q.ninvoke pag, 'send'
    .then (pagseguroResult) ->
      if pagseguroResult is 'Unauthorized' then throw new Error 'Loja não autorizada no PagSeguro'
      parseXml pagseguroResult
    .then (pagseguroResult) ->
      if pagseguroResult.errors?
        err = new Error "Errors happened on PagSeguro"
        err.pagSeguroErrors = pagseguroResult.errors
        throw err
      pagseguroResult.checkout.code

  redirectUrl: (pagseguroCode) -> "https://pagseguro.uol.com.br/v2/checkout/payment.html?code=#{pagseguroCode}"
