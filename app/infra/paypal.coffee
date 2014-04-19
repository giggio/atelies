paypal          = require 'paypal-rest-sdk'
Q               = require 'q'
_               = require 'underscore'

module.exports = class Paypal
  @init: (opt) ->
    @host = opt.host
    @port = opt.port
    paypal.configure host: opt.host, port: opt.port
  sendToPaypal: (store, order, user) ->
    paypalPayment =
      intent: "sale"
      payer: payment_method: "paypal"
      redirect_urls:
        return_url: "#{CONFIG.secureUrl}/paymentGateway/paypal/#{store.slug}/returnFromPayment/#{order._id}/success"
        cancel_url: "#{CONFIG.secureUrl}/paymentGateway/paypal/#{store.slug}/returnFromPayment/#{order._id}/fail"
      transactions: [
        amount:
          currency: "BRL"
          total: order.totalSaleAmount.toFixed 2
          details:
            shipping: order.shippingCost.toFixed 2
            subtotal: order.totalProductsPrice.toFixed 2
        description: "Compra na loja #{store.name}"
        item_list:
          items: []
      ]
    paypalPayment.transactions[0].item_list.items =
      for item in order.items
        quantity: item.quantity
        name: item.name
        price: item.price.toFixed 2
        currency: 'BRL'
    opt =
      client_id: store.pmtGateways.paypal.clientId
      client_secret: store.pmtGateways.paypal.secret
    Q.nfcall paypal.payment.create, paypalPayment, opt
    .then (resp) ->
      redirectLink = _.findWhere resp.links, rel: "approval_url"
      redirectUrl: redirectLink.href, paypalInfo: id: resp.id, state: resp.state

  confirmPayment: (order, store, payerId) ->
    opt =
      client_id: store.pmtGateways.paypal.clientId
      client_secret: store.pmtGateways.paypal.secret
    Q.ninvoke paypal.payment, 'execute', order.paymentGatewayInfo.paypal.id, payer_id: payerId, opt
    .then (resp) -> id: resp.id, state: resp.state
