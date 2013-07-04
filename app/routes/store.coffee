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
      res.render "store", {store: store.toSimple(), products: viewModelProducts, user: user}, (err, html) ->
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
      items = []
      errors = []
      for item in req.body.items
        do (item) ->
          Product.findById item._id, (err, prod) ->
            if err
              errors.push err
            else
              items.push product: prod, quantity: item.quantity
      foundProducts = =>
        return setImmediate foundProducts unless errors.length + items.length is req.body.items.length
        return res.json 400, errors if errors.length > 0
        @_calculateShippingForOrder store, req.body, req.user, req.body.shippingType, (error, shippingCost) =>
          Order.create user, store, items, shippingCost, (order) =>
            order.save (err, order) =>
              if err?
                res.json 400, err
              else
                for item in items
                  p = item.product
                  p.inventory -= item.quantity if p.hasInventory
                  p.save()
                order.sendMailAfterPurchase (error, mailResponse) ->
                  console.log "Error sending mail: #{error}" if error?
                  res.json 201, order.toSimpleOrder()
      process.nextTick foundProducts

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
                pac.cost += delivery.GrandTotal * quantity
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
