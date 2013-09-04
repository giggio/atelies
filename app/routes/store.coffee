Product         = require '../models/product'
User            = require '../models/user'
Store           = require '../models/store'
Order           = require '../models/order'
StoreEvaluation = require '../models/storeEvaluation'
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

module.exports = class StoreRoutes
  constructor: (@env, @domain) ->
    @_auth 'orderCreate', 'calculateShipping', 'commentCreate'
    @_authVerified 'orderCreate'
  _.extend @::, RouteFunctions::

  handleError: @::_handleError.partial 'store'

  logError: @::_logError.partial 'store'
  
  store: (req, res) ->
    subdomain = @_getSubdomain @domain, req.host.toLowerCase()
    return res.redirect "#{req.protocol}://#{req.headers.host}/" if subdomain? and req.params.storeSlug isnt subdomain
    Store.findWithProductsBySlug req.params.storeSlug, (err, store, products) =>
      return @handleError req, res, err, false if err?
      return res.renderWithCode 404, 'storeNotFound', store: null, products: [] if store is null
      viewModelProducts = _.map products, (p) -> p.toSimplerProduct()
      getUser = (cb) =>
        if req.user?
          req.user.toSimpleUser (user) -> cb user
        else
          cb undefined
      getUser (user) ->
        if req.session.recentOrder?
          order = req.session.recentOrder
          req.session.recentOrder = null
        res.render "store", {store: store.toSimple(), products: viewModelProducts, user: user, order: order}, (err, html) =>
          return @handleError req, res, err, false if err?
          res.send html

  product: (req, res) ->
    Product.findByStoreSlugAndSlug req.params.storeSlug, req.params.productSlug, (err, product) =>
      return @handleError req, res, err if err?
      return res.send 404 if product is null
      product.toSimpleProductWithComments (err, simpleProduct) =>
        return @handleError req, res, err if err?
        res.json simpleProduct
  
  orderCreate: (req, res) ->
    user = req.user
    Store.findById req.params.storeId, (err, store) =>
      return @handleError req, res, err if err?
      getItems = for item in req.body.items
        do (item) ->
          (cb) =>
            Product.findById item._id, (err, product) =>
              cb err, product: product, quantity: item.quantity
      async.parallel getItems, (errors, items) =>
        return @handleError req, res, err if err?
        @_calculateShippingForOrder store, req.body, req.user, req.body.shippingType, (err, shippingCost) =>
          return @handleError req, res, err if err?
          paymentType = req.body.paymentType
          Order.create user, store, items, shippingCost, paymentType, (err, order) =>
            return @handleError req, res, err if err?
            order.save (err, order) =>
              return @handleError req, res, err if err?
              for item in items
                p = item.product
                p.inventory -= item.quantity if p.hasInventory
                p.save()
              if store.pagseguro() and paymentType is 'pagseguro'
                @_sendToPagseguro store, order, user, (err, pagseguroCode) =>
                  return @handleError req, res, err if err?
                  res.json 201, order: order.toSimpleOrder(), redirect: "https://pagseguro.uol.com.br/v2/checkout/payment.html?code=#{pagseguroCode}"
              else
                order.sendMailAfterPurchase (err, mailResponse) =>
                  return @handleError req, res, err if err?
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
    Store.findBySlug req.params.storeSlug, (err, store) =>
      return @handleError req, res, err if err?
      notificationId = req.body.notificationCode
      @_getSalestatusFromPagseguroNotificationId notificationId, store.pmtGateways.pagseguro.email, store.pmtGateways.pagseguro.token, (err, orderId, saleStatus) ->
        Order.findById orderId, (err, order) =>
          return @handleError req, res, err if err?
          order.updateStatus saleStatus, (err) =>
            return @handleError req, res, err if err?
            res.send 200
  _getSalestatusFromPagseguroNotificationId: (notificationId, email, token, cb) ->
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
  pagseguroReturnFromPayment: (req, res) ->
    Store.findBySlug req.params.storeSlug, (err, store) =>
      return @handleError req, res, err, false if err?
      psTransactionId = req.query.transactionId
      @_getOrderIdFromPagseguroTransactionId psTransactionId, store.pmtGateways.pagseguro.email, store.pmtGateways.pagseguro.token, (err, orderId) =>
        return @handleError req, res, err, false if err?
        Order.findById orderId, (err, order) =>
          return @handleError req, res, err, false if err?
          order.sendMailAfterPurchase (err, mailResponse) =>
            return @handleError req, res, err, false if err?
            req.session.recentOrder = order.toSimpleOrder()
            order.populate 'store', 'slug', (err) =>
              return @handleError req, res, err, false if err?
              res.redirect "/#{order.store.slug}#finishOrder/orderFinished"

  _getOrderIdFromPagseguroTransactionId: (transactionId, email, token, cb) ->
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

  _calculateShippingForOrder: (store, data, user, shippingType, cb) ->
    return setImmediate(-> cb null, 0) unless shippingType?
    @_calculateShipping store.slug, data, user, (err, shippingOptions) ->
      return cb err if err?
      shippingOption = _.findWhere shippingOptions, type: shippingType
      shippingCost = shippingOption.cost
      cb null, shippingCost

  calculateShipping: (req, res) ->
    @_calculateShipping req.params.storeSlug, req.body, req.user, (err, shippingOptions) =>
      return @handleError req, res, err if err?
      res.json shippingOptions

  _calculateShipping: (storeSlug, data, user, cb) ->
    ids = _.map data.items, (i) -> i._id
    userZip = user.deliveryAddress.zip
    pac = type: 'pac', name: 'PAC', cost: 0, days: 0
    sedex = type: 'sedex', name: 'Sedex', cost: 0, days: 0
    shippingOptions = [ pac, sedex ]
    Store.findBySlug storeSlug, (err, store) ->
      return cb err if err?
      storeZip = store.zip
      Product.getShippingWeightAndDimensions ids, (err, products) ->
        getShippingPrices = []
        for p in products
          do (p) ->
            if p.hasShippingInfo()
              shipping = p.shipping
              quantity = parseInt _.findWhere(data.items, _id: p._id.toString()).quantity
              getShippingPrices.push (cb) =>
                deliverySpecs = serviceType: 'pac', from: storeZip, to: userZip, weight: shipping.weight, height: shipping.dimensions.height, width: shipping.dimensions.width, length: shipping.dimensions.depth
                correios.getPrice deliverySpecs, (err, delivery) ->
                  #console.log "got price for pac with specs #{JSON.stringify deliverySpecs}, with response #{JSON.stringify delivery}"
                  return cb err if err?
                  pac.cost += delivery.GrandTotal * quantity if p.shipping.charge
                  pac.days = delivery.estimatedDelivery if delivery.estimatedDelivery > pac.days
                  cb()
              getShippingPrices.push (cb) =>
                deliverySpecs = serviceType: 'sedex', from: storeZip, to: userZip, weight: shipping.weight, height: shipping.dimensions.height, width: shipping.dimensions.width, length: shipping.dimensions.depth
                correios.getPrice deliverySpecs, (err, delivery) ->
                  #console.log "got price for sedex with specs #{JSON.stringify deliverySpecs}, with response #{JSON.stringify delivery}"
                  return cb err if err?
                  sedex.cost += delivery.GrandTotal * quantity if p.shipping.charge
                  sedex.days = delivery.estimatedDelivery if delivery.estimatedDelivery > sedex.days
                  cb()
        async.parallel getShippingPrices, (err) ->
          return cb "Erro ao obter custo de postagem.\n#{err}" if err?
          cb null, shippingOptions
  
  productsSearch: (req, res) ->
    Product.searchByStoreSlugAndByName req.params.storeSlug, req.params.searchTerm, (err, products) =>
      return @handleError req, res, err if err?
      viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
      res.json viewModelProducts

  commentCreate: (req, res) ->
    Product.findById req.params.productId, (err, product) =>
      return @handleError req, res, err if err?
      product.addComment {user: req.user, body: req.body.body}, (err, comment) =>
        return @handleError req, res, err if err?
        comment.save()
        res.send 201

  evaluations: (req, res) ->
    StoreEvaluation.getSimpleFromStore req.params._id, (err, evals) =>
      return @handleError req, res, err if err?
      res.json evals
