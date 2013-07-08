Product         = require '../models/product'
User            = require '../models/user'
Store           = require '../models/store'
Order           = require '../models/order'
_               = require 'underscore'
everyauth       = require 'everyauth'
AccessDenied    = require '../errors/accessDenied'
values          = require '../helpers/values'
correios        = require 'correios'
RouteFunctions  = require './routeFunctions'
async           = require 'async'
pagseguro       = require 'pagseguro'
parseXml        = require('xml2js').parseString
request         = require 'request'

class Routes
  constructor: (@env, @domain) ->
    @_auth 'orderCreate', 'calculateShipping'
  
  store: (req, res) ->
    subdomain = @_getSubdomain @domain, req.host.toLowerCase()
    return res.redirect "#{req.protocol}://#{req.headers.host}/" if subdomain? and req.params.storeSlug isnt subdomain
    Store.findWithProductsBySlug req.params.storeSlug, (err, store, products) ->
      dealWith err
      return res.renderWithCode 404, 'storeNotFound', store: null, products: [] if store is null
      viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
      user =
        if req.user?
          name: req.user.name
          _id: req.user._id
          email: req.user.email
          deliveryAddress: req.user.deliveryAddress
          phoneNumber: req.user.phoneNumber
        else
          undefined
      if req.session.recentOrder?
        order = req.session.recentOrder
        req.session.recentOrder = null
      res.render "store", {store: store.toSimple(), products: viewModelProducts, user: user, order: order}, (err, html) ->
        #console.log html
        res.send html

  product: (req, res) ->
    Product.findByStoreSlugAndSlug req.params.storeSlug, req.params.productSlug, (err, product) ->
      dealWith err
      return res.send 404 if product is null
      res.json product.toSimpleProduct()
  
  orderCreate: (req, res) ->
    user = req.user
    Store.findById req.params.storeId, (err, store) =>
      dealWith err
      getItems = for item in req.body.items
        do (item) ->
          (cb) =>
            Product.findById item._id, (err, product) =>
              cb err, product: product, quantity: item.quantity
      async.parallel getItems, (errors, items) =>
        return res.json 400, errors if errors?
        @_calculateShippingForOrder store, req.body, req.user, req.body.shippingType, (error, shippingCost) =>
          Order.create user, store, items, shippingCost, (order) =>
            order.save (err, order) =>
              return res.json 400, err if err?
              for item in items
                p = item.product
                p.inventory -= item.quantity if p.hasInventory
                p.save()
              if store.pmtGateways.pagseguro?.token? and store.pmtGateways.pagseguro?.email?
                pag = new pagseguro store.pmtGateways.pagseguro.email, store.pmtGateways.pagseguro.token
                pag.currency 'BRL'
                pag.reference order._id.toString()
                for item, i in items
                  product = item.product
                  pagItem =
                    id: i + 1
                    description: product.name
                    amount: product.price.toFixed 2
                    quantity: item.quantity
                  pagItem.weight = item.weight if product.shipping?.weight?
                  pag.addItem pagItem
                pag.addItem
                  id: items.length
                  description: "Frete"
                  amount: shippingCost.toFixed 2
                  quantity: 1
                pag.buyer
                  name: user.name
                  email: user.email
                pag.send (err, pagseguroResult) =>
                  return res.json 400, err if err?
                  return res.json 400, errorMsg: 'Loja não autorizada no PagSeguro' if pagseguroResult is 'Unauthorized'
                  parseXml pagseguroResult, (err, pagseguroResult) =>
                    return res.json 400, err if err?
                    return res.json 400, pagseguroResult.errors if pagseguroResult.errors?
                    res.json 201, order: order.toSimpleOrder(), redirect: "https://pagseguro.uol.com.br/v2/checkout/payment.html?code=#{pagseguroResult.checkout.code}"
              else
                order.sendMailAfterPurchase (error, mailResponse) ->
                  console.log "Error sending mail: #{error}" if error?
                  res.json 201, order.toSimpleOrder()

  pagseguroStatusChanged: (req, res) ->
    Store.findBySlug req.params.storeSlug, (err, store) ->
      notificationId = req.body.notificationCode
      @_getSalestatusFromPagseguroNotificationId notificationId, store.pmtGateways.pagseguro.email, store.pmtGateways.pagseguro.token, (err, orderId, saleStatus) ->
        Order.findById orderId, (err, order) =>
          order.updateStatus saleStatus, (err) =>
            res.send 200
  _getSalestatusFromPagseguroNotificationId: (notificationId, email, token, cb) ->
    url = "https://ws.pagseguro.uol.com.br/v2/transactions/notifications/#{notificationId}?email=#{email}&token=#{token}"
    request url, (error, response, body) ->
      return cb error if error?
      if response.statusCode isnt 200
        return parseXml body, {explicitArray: false}, (error, errorResult) ->
          errorMsg = errorResult.errors.error.message
          cb new Error "Not a 200 status code response. Error: #{errorMsg}"
      parseXml body, (error, psTransaction) ->
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
  pagseguroReturnFromPayment: (req, res) ->
    Store.findBySlug req.params.storeSlug, (err, store) =>
      psTransactionId = req.query.transactionId
      @_getOrderIdFromPagseguroTransactionId psTransactionId, store.pmtGateways.pagseguro.email, store.pmtGateways.pagseguro.token, (err, orderId) =>
        return res.redirect "/error?msg=#{err}" if err?
        Order.findById orderId, (err, order) =>
          order.sendMailAfterPurchase (error, mailResponse) =>
            console.log "Error sending mail: #{error}" if error?
            req.session.recentOrder = order.toSimpleOrder()
            order.populate 'store', 'slug', (err) ->
              res.redirect "/#{order.store.slug}/finishOrder/orderFinished"

  _getOrderIdFromPagseguroTransactionId: (transactionId, email, token, cb) ->
    url = "https://ws.pagseguro.uol.com.br/v2/transactions/#{transactionId}?email=#{email}&token=#{token}"
    request url, (error, response, body) ->
      return cb error if error?
      if response.statusCode isnt 200
        return parseXml body, {explicitArray: false}, (error, errorResult) ->
          errorMsg = errorResult.errors.error.message
          cb new Error "Not a 200 status code response. Error: #{errorMsg}"
      parseXml body, (error, psTransaction) ->
        orderId = psTransaction.transaction.reference
        cb null, orderId

  _calculateShippingForOrder: (store, data, user, shippingType, cb) ->
    if store.autoCalculateShipping
      @_calculateShipping store.slug, data, user, (error, shippingOptions) ->
        cb error if error?
        shippingOption = _.findWhere shippingOptions, type: shippingType
        shippingCost = shippingOption.cost
        cb null, shippingCost
    else
      setImmediate -> cb null, 0

  calculateShipping: (req, res) ->
    @_calculateShipping req.params.storeSlug, req.body, req.user, (error, shippingOptions) ->
      return res.send 500, error: "Não pode calcular postagem para loja que não optou por cálculo automático via Correios." if error
      res.json shippingOptions

  _calculateShipping: (storeSlug, data, user, cb) ->
    ids = _.map data.items, (i) -> i._id
    userZip = user.deliveryAddress.zip
    pac = type: 'pac', name: 'PAC', cost: 0, days: 0
    sedex = type: 'sedex', name: 'Sedex', cost: 0, days: 0
    shippingOptions = [ pac, sedex ]
    Store.findBySlug storeSlug, (err, store) ->
      cb "Não pode calcular postagem para loja que não optou por cálculo automático via Correios." unless store.autoCalculateShipping
      storeZip = store.zip
      Product.getShippingWeightAndDimensions ids, (err, products) ->
        callbacks = 0
        for p in products
          do (p) ->
            if p.hasShippingInfo()
              shipping = p.shipping
              quantity = parseInt _.findWhere(data.items, _id: p._id.toString()).quantity
              deliverySpecs =
                serviceType: 'pac'
                from: storeZip
                to: userZip
                weight: shipping.weight
                height: shipping.dimensions.height
                width: shipping.dimensions.width
                length: shipping.dimensions.depth
              callbacks++
              correios.getPrice deliverySpecs, (err, delivery) ->
                callbacks--
                dealWith err
                #TODO: remover
                #pac.cost += delivery.GrandTotal * quantity
                pac.cost = 0.01
                pac.days = delivery.estimatedDelivery if delivery.estimatedDelivery > pac.days
              callbacks++
              deliverySpecs.serviceType = 'sedex'
              correios.getPrice deliverySpecs, (err, delivery) ->
                callbacks--
                dealWith err
                sedex.cost += delivery.GrandTotal * quantity
                sedex.days = delivery.estimatedDelivery if delivery.estimatedDelivery > sedex.days
        ready = ->
          if callbacks is 0
            cb null, shippingOptions
          else
            setImmediate ready
        ready()
  
_.extend Routes::, RouteFunctions::

module.exports = Routes
