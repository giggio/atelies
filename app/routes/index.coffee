Product         = require '../models/product'
User            = require '../models/user'
Store           = require '../models/store'
Order           = require '../models/order'
_               = require 'underscore'
everyauth       = require 'everyauth'
AccessDenied    = require '../errors/accessDenied'
values          = require '../helpers/values'

class Routes
  constructor: (@env) ->
    @_auth 'changePasswordShow', 'changePassword', 'passwordChanged', 'admin', 'updateProfile', 'updateProfileShow', 'profileUpdated', 'orderCreate'
    @_authSeller 'adminStoreCreate', 'adminStoreUpdate', 'adminProductUpdate', 'adminProductDelete', 'adminProductCreate'

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
    store.otherUrl = body.otherUrl
    store.banner = body.banner
    store.flyer = body.flyer
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
      store.otherUrl = body.otherUrl
      store.banner = body.banner
      store.flyer = body.flyer
      store.save (err) ->
        if err?
          return res.json 400
        res.send 200, store

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
    Store.findById req.params.storeId, (err, store) ->
      dealWith err
      shippingCost = 1
      items = []
      errors = []
      for item in req.body.items
        do (item) ->
          Product.findById item._id, (err, prod) ->
            if err
              errors.push err
            else
              items.push product: prod, quantity: item.quantity
      foundProducts = ->
        if errors.length + items.length is req.body.items.length
          if errors.length > 0
            res.json 400, errors
          Order.create user, store, items, shippingCost, (order) ->
            order.save (err, order) ->
              if err?
                res.json 400, err
              else
                for item in items
                  p = item.product
                  p.inventory -= item.quantity
                  p.save()
                res.json 201, order.toSimpleOrder()
        else
          setImmediate foundProducts
      process.nextTick foundProducts

module.exports = Routes
