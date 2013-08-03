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
    @_authVerified 'orderCreate'
  
  store: (req, res) ->
    subdomain = @_getSubdomain @domain, req.host.toLowerCase()
    return res.redirect "#{req.protocol}://#{req.headers.host}/" if subdomain? and req.params.storeSlug isnt subdomain
    Store.findWithProductsBySlug req.params.storeSlug, (err, store, products) ->
      return res.send 400 if err?
      return res.renderWithCode 404, 'storeNotFound', store: null, products: [] if store is null
      viewModelProducts = _.map products, (p) -> p.toSimplerProduct()
      user =
        if req.user?
          req.user.toSimpleUser()
        else
          undefined
      if req.session.recentOrder?
        order = req.session.recentOrder
        req.session.recentOrder = null
      res.render "store", {store: store.toSimple(), products: viewModelProducts, user: user, order: order}, (err, html) ->
        #console.log html
        return res.send 400 if err?
        res.send html

  product: (req, res) ->
    Product.findByStoreSlugAndSlug req.params.storeSlug, req.params.productSlug, (err, product) ->
      return res.send 400 if err?
      return res.send 404 if product is null
      res.json product.toSimpleProduct()
  
  orderCreate: (req, res) ->
    user = req.user
    Store.findById req.params.storeId, (err, store) =>
      return res.send 400 if err?
      getItems = for item in req.body.items
        do (item) ->
          (cb) =>
            Product.findById item._id, (err, product) =>
              cb err, product: product, quantity: item.quantity
      async.parallel getItems, (errors, items) =>
        return res.send 400 if errors?
        @_calculateShippingForOrder store, req.body, req.user, req.body.shippingType, (err, shippingCost) =>
          return res.json 400, err if err?
          paymentType = req.body.paymentType
          Order.create user, store, items, shippingCost, paymentType, (order) =>
            order.save (err, order) =>
              return res.json 400, err if err?
              for item in items
                p = item.product
                p.inventory -= item.quantity if p.hasInventory
                p.save()
              if store.pagseguro() and paymentType is 'pagseguro'
                @_sendToPagseguro store, order, user, (err, pagseguroCode) =>
                  return res.send 400 if err?
                  res.json 201, order: order.toSimpleOrder(), redirect: "https://pagseguro.uol.com.br/v2/checkout/payment.html?code=#{pagseguroCode}"
              else
                order.sendMailAfterPurchase (error, mailResponse) ->
                  return res.send 400 if err?
                  simpleOrder = order.toSimpleOrder()
                  res.json 201, simpleOrder

  _sendToPagseguro: (store, order, user, cb) ->
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
    pag.addItem
      id: order.items.length
      description: "Frete"
      amount: order.shippingCost.toFixed 2
      quantity: 1
    pag.buyer
      name: user.name
      email: user.email
    pag.send (err, pagseguroResult) =>
      return cb err if err?
      return cb errorMsg: 'Loja não autorizada no PagSeguro' if pagseguroResult is 'Unauthorized'
      parseXml pagseguroResult, (err, pagseguroResult) =>
        return cb err if err?
        return cb pagseguroResult.errors if pagseguroResult.errors?
        cb null, pagseguroResult.checkout.code

  pagseguroStatusChanged: (req, res) ->
    Store.findBySlug req.params.storeSlug, (err, store) ->
      return res.send 400 if err?
      notificationId = req.body.notificationCode
      @_getSalestatusFromPagseguroNotificationId notificationId, store.pmtGateways.pagseguro.email, store.pmtGateways.pagseguro.token, (err, orderId, saleStatus) ->
        Order.findById orderId, (err, order) =>
          return res.send 400 if err?
          order.updateStatus saleStatus, (err) =>
            return res.send 400 if err?
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
      return res.send 400 if err?
      psTransactionId = req.query.transactionId
      @_getOrderIdFromPagseguroTransactionId psTransactionId, store.pmtGateways.pagseguro.email, store.pmtGateways.pagseguro.token, (err, orderId) =>
        return res.redirect "/error?msg=#{err}" if err?
        Order.findById orderId, (err, order) =>
          return res.send 400 if err?
          order.sendMailAfterPurchase (err, mailResponse) =>
            return res.send 400 if err?
            #console.log "Error sending mail: #{error}" if err?
            req.session.recentOrder = order.toSimpleOrder()
            order.populate 'store', 'slug', (err) ->
              return res.send 400 if err?
              res.redirect "/#{order.store.slug}#finishOrder/orderFinished"

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
      @_calculateShipping store.slug, data, user, (err, shippingOptions) ->
        return cb err if err?
        shippingOption = _.findWhere shippingOptions, type: shippingType
        shippingCost = shippingOption.cost
        cb null, shippingCost
    else
      setImmediate -> cb null, 0

  calculateShipping: (req, res) ->
    @_calculateShipping req.params.storeSlug, req.body, req.user, (err, shippingOptions) ->
      return res.json 400, err if err?
      res.json shippingOptions

  _calculateShipping: (storeSlug, data, user, cb) ->
    ids = _.map data.items, (i) -> i._id
    userZip = user.deliveryAddress.zip
    pac = type: 'pac', name: 'PAC', cost: 0, days: 0
    sedex = type: 'sedex', name: 'Sedex', cost: 0, days: 0
    shippingOptions = [ pac, sedex ]
    Store.findBySlug storeSlug, (err, store) ->
      return cb err if err?
      return cb "Não pode calcular postagem para loja que não optou por cálculo automático via Correios." unless store.autoCalculateShipping
      storeZip = store.zip
      Product.getShippingWeightAndDimensions ids, (err, products) ->
        callbacks = 0
        errors = []
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
                return errors.push(err) if err?
                pac.cost += delivery.GrandTotal * quantity
                #pac.cost = 0.01
                pac.days = delivery.estimatedDelivery if delivery.estimatedDelivery > pac.days
              callbacks++
              deliverySpecs.serviceType = 'sedex'
              correios.getPrice deliverySpecs, (err, delivery) ->
                callbacks--
                return errors.push(err) if err?
                sedex.cost += delivery.GrandTotal * quantity
                sedex.days = delivery.estimatedDelivery if delivery.estimatedDelivery > sedex.days
        ready = ->
          if callbacks is 0
            return cb "Erro ao obter custo de postagem.#{errors}" if errors.length > 0
            cb null, shippingOptions
          else
            setImmediate ready
        ready()
  
  productsSearch: (req, res) ->
    Product.searchByStoreSlugAndByName req.params.storeSlug, req.params.searchTerm, (err, products) ->
      return res.send 400 if err?
      viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
      res.json viewModelProducts

_.extend Routes::, RouteFunctions::

module.exports = Routes
