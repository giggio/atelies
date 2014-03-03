Product         = require '../models/product'
User            = require '../models/user'
Store           = require '../models/store'
Order           = require '../models/order'
StoreEvaluation = require '../models/storeEvaluation'
_               = require 'underscore'
RouteFunctions  = require './routeFunctions'
async           = require 'async'
PostOffice      = require '../infra/postOffice'
PagSeguro       = require '../infra/pagseguro'

module.exports = class StoreRoutes
  constructor: (@env, @domain) ->
    @_auth 'orderCreate', 'calculateShipping', 'commentCreate'
    @_authVerified 'orderCreate'
    @postOffice = new PostOffice()
    @pagseguro = new PagSeguro()
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
        @_calculateShippingForOrder store.zip, req.body.items, req.user.deliveryAddress.zip, req.body.shippingType, (err, shippingCost) =>
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
                @pagseguro.sendToPagseguro store, order, user, (err, pagseguroCode) =>
                  return @handleError req, res, err if err?
                  res.json 201, order: order.toSimpleOrder(), redirect: @pagseguro.redirectUrl pagseguroCode
              else
                order.sendMailAfterPurchase (err, mailResponse) =>
                  return @handleError req, res, err if err?
                  simpleOrder = order.toSimpleOrder()
                  res.json 201, simpleOrder

  pagseguroStatusChanged: (req, res) ->
    Store.findBySlug req.params.storeSlug, (err, store) =>
      return @handleError req, res, err if err?
      notificationId = req.body.notificationCode
      @pagseguro.getSalestatusFromPagseguroNotificationId notificationId, store.pmtGateways.pagseguro.email, store.pmtGateways.pagseguro.token, (err, orderId, saleStatus) ->
        Order.findById orderId, (err, order) =>
          return @handleError req, res, err if err?
          order.updateStatus saleStatus, (err) =>
            return @handleError req, res, err if err?
            res.send 200

  pagseguroReturnFromPayment: (req, res) ->
    Store.findBySlug req.params.storeSlug, (err, store) =>
      return @handleError req, res, err, false if err?
      psTransactionId = req.query.transactionId
      @pagseguro.getOrderIdFromPagseguroTransactionId psTransactionId, store.pmtGateways.pagseguro.email, store.pmtGateways.pagseguro.token, (err, orderId) =>
        return @handleError req, res, err, false if err?
        Order.findById orderId, (err, order) =>
          return @handleError req, res, err, false if err?
          order.sendMailAfterPurchase (err, mailResponse) =>
            return @handleError req, res, err, false if err?
            req.session.recentOrder = order.toSimpleOrder()
            order.populate 'store', 'slug', (err) =>
              return @handleError req, res, err, false if err?
              res.redirect "/#{order.store.slug}#finishOrder/orderFinished"

  _calculateShippingForOrder: (storeZip, items, userZip, shippingType, cb) =>
    return setImmediate(-> cb null, 0) unless shippingType?
    @postOffice.calculateShipping storeZip, items, userZip, (err, shippingOptions) ->
      return cb err if err?
      shippingOption = _.findWhere shippingOptions, type: shippingType
      shippingCost = shippingOption.cost
      cb null, shippingCost

  calculateShipping: (req, res) ->
    Store.findBySlug req.params.storeSlug, (err, store) =>
      return cb err if err?
      @postOffice.calculateShipping store.zip, req.body.items, req.user.deliveryAddress.zip, (err, shippingOptions) =>
        return @handleError req, res, err if err?
        res.json shippingOptions

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
