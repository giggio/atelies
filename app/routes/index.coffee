Product         = require '../models/product'
User            = require '../models/user'
Store           = require '../models/store'
Order           = require '../models/order'
_               = require 'underscore'
everyauth       = require 'everyauth'
AccessDenied    = require '../errors/accessDenied'
values          = require '../helpers/values'
correios        = require 'correios'

class Routes
  constructor: (@env) ->
    @_auth 'changePasswordShow', 'changePassword', 'passwordChanged', 'admin', 'updateProfile', 'updateProfileShow', 'profileUpdated', 'orderCreate', 'account', 'calculateShipping'
    @_authSeller 'adminStoreCreate', 'adminStoreUpdate', 'adminProductUpdate', 'adminProductDelete', 'adminProductCreate', 'adminStoreUpdateSetAutoCalculateShippingOff', 'adminStoreUpdateSetAutoCalculateShippingOn'

  _auth: ->
    for fn in arguments
      do (fn) =>
        original = @[fn]
        @[fn] = (req, res) ->
          return res.redirect "/account/login?redirectTo=#{req.originalUrl}" unless req.loggedIn
          original.apply @, arguments

  _authSeller: ->
    for fn in arguments
      do (fn) =>
        original = @[fn]
        @[fn] = (req, res) ->
          throw new AccessDenied() unless req.loggedIn and req.user?.isSeller
          original.apply @, arguments
  
  updateProfileShow: (req, res) ->
    user = req.user
    redirectTo = if req.query.redirectTo? then "?redirectTo=#{encodeURIComponent req.query.redirectTo}" else ""
    res.render 'updateProfile', user:
      name: user.name
      deliveryStreet: user.deliveryAddress.street
      deliveryStreet2: user.deliveryAddress.street2
      deliveryCity: user.deliveryAddress.city
      deliveryState: user.deliveryAddress.state
      deliveryZIP: user.deliveryAddress.zip
      phoneNumber: user.phoneNumber
      isSeller: user.isSeller
    , states: values.states, redirectTo: redirectTo

  updateProfile: (req, res) ->
    user = req.user
    body = req.body
    user.name = body.name
    user.deliveryAddress.street = body.deliveryStreet
    user.deliveryAddress.street2 = body.deliveryStreet2
    user.deliveryAddress.city = body.deliveryCity
    user.deliveryAddress.state = body.deliveryState
    user.deliveryAddress.zip = body.deliveryZIP
    user.phoneNumber = body.phoneNumber
    user.isSeller = true if body.isSeller
    user.save (error, user) =>
      if error?
        res.render 'updateProfile', errors: error.errors, user: body, states: values.states
      else
        redirectTo = if req.query.redirectTo? then "?redirectTo=#{encodeURIComponent req.query.redirectTo}" else ""
        res.redirect "account/profileUpdated#{redirectTo}"

  profileUpdated: (req, res) ->
    res.render 'profileUpdated', redirectTo: req.query.redirectTo
  
  changePasswordShow: (req, res) ->
    res.render 'changePassword'
  
  changePassword: (req, res) ->
    user = req.user
    email = user.email.toLowerCase()
    user.verifyPassword req.body.password, (error, succeeded) ->
      dealWith error
      if succeeded
        user.setPassword req.body.newPassword
        user.save (error, user) ->
          dealWith error
          res.redirect 'account/passwordChanged'
      else
        res.render 'changePassword', errors: [ 'Senha inválida.' ]
  
  passwordChanged: (req, res) ->
    res.render 'passwordChanged'
  
  admin: (req, res) ->
    return res.redirect 'notseller' unless req.user.isSeller
    req.user.populate 'stores', (err, user) ->
      res.render 'admin', stores: user.stores

  blank: (req, res) ->
    res.render 'blank'
  
  notSeller: (req, res) -> res.render 'notseller'
 
  adminStoreCreate: (req, res) ->
    store = req.user.createStore()
    body = req.body
    store.name = body.name
    store.email = body.email
    store.description = body.description
    store.homePageDescription = body.homePageDescription
    store.homePageImage = body.homePageImage
    store.urlFacebook = body.urlFacebook
    store.urlTwitter = body.urlTwitter
    store.phoneNumber = body.phoneNumber
    store.city = body.city
    store.state = body.state
    store.zip = body.zip
    store.otherUrl = body.otherUrl
    store.banner = body.banner
    store.flyer = body.flyer
    store.autoCalculateShipping = body.autoCalculateShipping
    store.save (err) ->
      return res.json 400, err if err?
      req.user.save (err) ->
        if err?
          store.remove()
          return res.json 400
        res.json 201, store
  
  adminStoreUpdate: (req, res) ->
    Store.findById req.params.storeId, (err, store) ->
      dealWith err
      throw new AccessDenied() unless req.user.hasStore store
      body = req.body
      store.name = body.name
      store.email = body.email
      store.description = body.description
      store.homePageDescription = body.homePageDescription
      store.homePageImage = body.homePageImage
      store.urlFacebook = body.urlFacebook
      store.urlTwitter = body.urlTwitter
      store.phoneNumber = body.phoneNumber
      store.city = body.city
      store.state = body.state
      store.zip = body.zip
      store.otherUrl = body.otherUrl
      store.banner = body.banner
      store.flyer = body.flyer
      store.save (err) ->
        if err?
          return res.json 400
        res.send 200, store
  adminStoreUpdateSetAutoCalculateShippingOff: (req, res) -> @_adminStoreUpdateSetAutoCalculateShipping req, res, off
  adminStoreUpdateSetAutoCalculateShippingOn: (req, res) -> @_adminStoreUpdateSetAutoCalculateShipping req, res, on
  _adminStoreUpdateSetAutoCalculateShipping: (req, res, autoCalculateShipping) ->
    Store.findById req.params.storeId, (err, store) ->
      dealWith err
      throw new AccessDenied() unless req.user.hasStore store
      store.setAutoCalculateShipping autoCalculateShipping, (set) ->
        if set
          store.save (err) ->
            return res.json 400 if err?
            res.send 204
        else
          res.send 409

  _getSubdomain: (domain, host) ->
    return undefined if @env isnt 'production' and host is 'localhost'
    if host isnt domain and host isnt "www.#{domain}"
      subdomain = host.replace ".#{domain}", ''
    subdomain

  index: (domain) ->
    route = (req, res) =>
      subdomain = @_getSubdomain domain, req.host.toLowerCase()
      if subdomain?
        req.params.storeSlug = subdomain
        return @storeWithDomain req, res
      Product.find (err, products) ->
        dealWith err
        viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
        Store.findForHome (err, stores) ->
          dealWith err
          res.render "index", products: viewModelProducts, stores: stores
    route
  
  store: (domain) ->
    @storeWithDomain = (req, res) =>
      subdomain = @_getSubdomain domain, req.host.toLowerCase()
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
        res.render "store", {store: store, products: viewModelProducts, user: user}, (err, html) ->
          #console.log html
          res.send html
    @storeWithDomain
  
  storeProducts: (req, res) ->
    Product.findByStoreSlug req.params.storeSlug, (err, products) ->
      dealWith err
      viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
      res.json viewModelProducts
  
  adminProductUpdate: (req, res) ->
    Product.findById req.params.productId, (err, product) ->
      dealWith err
      Store.findBySlug product.storeSlug, (err, store) ->
        dealWith err
        throw new AccessDenied() unless req.user.hasStore store
        product.updateFromSimpleProduct req.body
        product.save (err) ->
          res.send 204
  
  adminProductDelete: (req, res) ->
    Product.findById req.params.productId, (err, product) ->
      dealWith err
      Store.findBySlug product.storeSlug, (err, store) ->
        dealWith err
        throw new AccessDenied() unless req.user.hasStore store
        product.remove (err) ->
          res.send 204
  
  adminProductCreate: (req, res) ->
    Store.findBySlug req.params.storeSlug, (err, store) ->
      dealWith err
      throw new AccessDenied() unless req.user.hasStore store
      product = new Product()
      product.updateFromSimpleProduct req.body
      product.storeName = store.name
      product.storeSlug = store.slug
      product.save (err) ->
        res.send 201, product.toSimpleProduct()
  
  storeProduct: (req, res) ->
    Product.findById req.params.productId, (err, product) ->
      dealWith err
      if product?
        res.json product.toSimpleProduct()
      else
        res.send 404
  
  product: (req, res) ->
    Product.findByStoreSlugAndSlug req.params.storeSlug, req.params.productSlug, (err, product) ->
      dealWith err
      return res.send 404 if product is null
      res.json product.toSimpleProduct()
  
  storesSearch: (req, res) ->
    Store.searchByName req.params.searchTerm, (err, stores) ->
      dealWith err
      res.json stores
  
  productsSearch: (req, res) ->
    Product.searchByName req.params.searchTerm, (err, products) ->
      dealWith err
      viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
      res.json viewModelProducts

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
        @_calculateShippingForOrder store, req.body, req.user, req.body.shippingType, (error, shippingCost) ->
          Order.create user, store, items, shippingCost, (order) ->
            order.save (err, order) ->
              if err?
                res.json 400, err
              else
                for item in items
                  p = item.product
                  p.inventory -= item.quantity if p.hasInventory
                  p.save()
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

  account: (req, res) ->
    user = req.user
    Order.getSimpleByUser user, (err, orders) ->
      res.render 'account', user: user.toSimpleUser(), orders: orders

  order: (req, res) ->
    user = req.user
    Order.getSimpleWithItemsByUserAndId user, req.params._id, (err, orders) ->
      return res.json 400, err if err?
      res.json orders

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

module.exports = Routes
