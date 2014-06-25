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
Paypal          = require '../infra/paypal'
Q               = require 'q'

module.exports = class StoreRoutes
  constructor: (@env, @domain) ->
    @_auth 'orderCreate', 'calculateShipping', 'commentCreate'
    @_authVerified 'orderCreate'
    @postOffice = new PostOffice()
    @pagseguro = new PagSeguro()
    @paypal = new Paypal()
  _.extend @::, RouteFunctions::

  handleError: @::_handleError.partial 'store'

  logError: @::_logError.partial 'store'
  
  store: (req, res) ->
    subdomain = @_getSubdomain @domain, req.headers.host.toLowerCase()
    return res.redirect "#{req.protocol}://#{req.headers.host}/" if subdomain? and req.params.storeSlug isnt subdomain
    Store.findWithProductsBySlug req.params.storeSlug
    .spread (store, products) ->
      throw new Error "store not found" unless store?
      Q.fcall -> if req.user? then req.user.toSimpleUser() else undefined
      .then (user) -> [user, store, products]
    .spread (user, store, products) ->
      viewModelProducts = _.map products, (p) -> p.toSimplerProduct()
      if req.session.recentOrder?
        order = req.session.recentOrder
        req.session.recentOrder = null
      res.render "store/store", store: store.toSimple(), products: viewModelProducts, user: user, order: order, evaluationAvgRating: store.evaluationAvgRating, numberOfEvaluations: store.numberOfEvaluations, hasEvaluations: store.numberOfEvaluations > 0
    .catch (err) =>
      console.log err
      return res.renderWithCode 404, 'store/storeNotFound', store: null, products: [] if err.message is "store not found"
      @handleError req, res, err, false

  product: (req, res) ->
    Product.findByStoreSlugAndSlug req.params.storeSlug, req.params.productSlug
    .then (product) ->
      return null unless product?
      product.toSimpleProductWithComments()
    .then (simpleProduct) -> if simpleProduct? then res.json simpleProduct else res.send 404
    .catch (err) => @handleError req, res, err
  
  orderCreate: (req, res) ->
    Q(Store.findById(req.params.storeId).exec()).then (store) =>
      Q.fcall =>
        return 0 unless req.body.shippingType?
        @postOffice.calculateShipping store.zip, req.body.items, req.user.deliveryAddress.zip
        .then (shippingOptions) ->
          shippingOption = _.findWhere shippingOptions, type: req.body.shippingType
          shippingOption.cost
      .then (shippingCost) =>
        getItems = for item in req.body.items
          do (item) ->
            (cb) ->
              Product.findById item._id, (err, product) ->
                cb err, product: product, quantity: item.quantity
        Q.nfcall async.parallel, getItems
        .then (items) =>
          Order.create req.user, store, items, shippingCost, req.body.paymentType
          .then (order) -> Q.ninvoke order, 'save'
          .spread (order) =>
            for item in items
              p = item.product
              p.inventory -= item.quantity if p.hasInventory
              p.save()
            if req.body.paymentType is 'paypal' and store.paypal()
              @paypal.sendToPaypal store, order, req.user
              .then (resp) ->
                order.updatePaypalInfo resp.paypalInfo
                order.save()
                res.json 201, order: order.toSimpleOrder(), redirect: resp.redirectUrl
            else if req.body.paymentType is 'pagseguro' and store.pagseguro()
              @pagseguro.sendToPagseguro store, order, req.user
              .then (pagseguroCode) => res.json 201, order: order.toSimpleOrder(), redirect: @pagseguro.redirectUrl pagseguroCode
            else
              order.sendMailAfterPurchase()
              .spread (order) -> res.json 201, order.toSimpleOrder()
    .catch (err) => @handleError req, res, err

  pagseguroStatusChanged: (req, res) ->
    Store.findBySlug req.params.storeSlug
    .then (store) =>
      notificationId = req.body.notificationCode
      @pagseguro.getSalestatusFromPagseguroNotificationId notificationId, store.pmtGateways.pagseguro.email, store.pmtGateways.pagseguro.token
    .spread (orderId, saleStatus) -> Q.ninvoke Order, 'findById', orderId
    .then (order) -> order.updateStatus saleStatus
    .then -> res.send 200
    .catch (err) => @handleError req, res, err

  paypalReturnFromPayment: (req, res) ->
    if req.params.result is 'fail'
      return res.redirect "/#{req.params.storeSlug}/finishOrder/orderNotCompleted"
    Q.all [
      Q.ninvoke Store, 'findBySlug', req.params.storeSlug
      Q.ninvoke Order, "findById", req.params.orderId
    ]
    .spread (store, order) =>
      throw new Error "Store id #{store._id} doesn't match store id (#{order.store}) from order #{order._id}." unless order.store.equals store._id
      req.session.recentOrder = order.toSimpleOrder()
      @paypal.confirmPayment order, store, req.query['PayerID']
      .then (paypalInfo) ->
        order.updatePaypalInfo paypalInfo
        order.state = 'paymentDone'
        Q.ninvoke order, 'save'
      .then -> order.sendMailAfterPurchase()
      .then -> res.redirect "/#{store.slug}/finishOrder/orderFinished"
    .catch (err) => @handleError req, res, err, false

  pagseguroReturnFromPayment: (req, res) ->
    Store.findBySlug req.params.storeSlug
    .then (store) =>
      psTransactionId = req.query.transactionId
      [store, @pagseguro.getOrderIdFromPagseguroTransactionId psTransactionId, store.pmtGateways.pagseguro.email, store.pmtGateways.pagseguro.token]
    .spread (store, orderId) -> [store, Q.ninvoke Order, 'findById', orderId]
    .spread (store, order) ->
      order.state = 'paymentDone'
      order.save()
      order.sendMailAfterPurchase()
      .then ->
        req.session.recentOrder = order.toSimpleOrder()
        res.redirect "/#{store.slug}/finishOrder/orderFinished"
    .catch (err) => @handleError req, res, err, false

  calculateShipping: (req, res) ->
    Q.nfcall Store.findBySlug, req.params.storeSlug
    .then (store) => @postOffice.calculateShipping store.zip, req.body.items, req.user.deliveryAddress.zip
    .then (shippingOptions) -> res.json shippingOptions
    .catch (err) => return @handleError req, res, err

  productsSearch: (req, res) ->
    Product.searchByStoreSlugAndByName req.params.storeSlug, req.params.searchTerm
    .catch (err) => @handleError req, res, err
    .then (products) ->
      viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
      res.json viewModelProducts

  commentCreate: (req, res) ->
    Q.ninvoke Product, 'findById', req.params.productId
    .then (product) -> product.addComment user: req.user, body: req.body.body
    .then (comment) -> Q.ninvoke comment, 'save'
    .then -> res.send 201
    .catch (err) => @handleError req, res, err

  evaluations: (req, res) ->
    StoreEvaluation.getSimpleFromStore req.params._id
    .then (evals) -> res.json evals
    .catch (err) => @handleError req, res, err
