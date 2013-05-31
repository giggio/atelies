Product         = require '../models/product'
User            = require '../models/user'
Store           = require '../models/store'
_               = require 'underscore'
everyauth       = require 'everyauth'
AccessDenied    = require '../errors/accessDenied'

class Routes
  constructor: ->
    @_auth 'changePasswordShow', 'changePassword', 'passwordChanged', 'admin'
    @_authSeller 'adminStoreCreate', 'adminStoreUpdate', 'adminProductUpdate', 'adminProductDelete', 'adminProductCreate'

  _auth: ->
    for fn in arguments
      do (fn) =>
        original = @[fn]
        @[fn] = (req, res) ->
          return res.redirect 'login' unless req.loggedIn
          original.apply @, arguments

  _authSeller: ->
    for fn in arguments
      do (fn) =>
        original = @[fn]
        @[fn] = (req, res) ->
          throw new AccessDenied() unless req.loggedIn and req.user?.isSeller
          original.apply @, arguments
  
  changePasswordShow: (req, res) ->
    res.render 'changePassword'
  
  changePassword: (req, res) ->
    user = req.user
    email = user.email.toLowerCase()
    user.verifyPassword req.body.password, (err, succeeded) ->
      dealWith err
      if succeeded
        user.setPassword req.body.newPassword
        user.save (error, user) ->
          dealWith err
          res.redirect 'account/passwordChanged'
      else
        res.render 'changePassword', errors: [ 'Senha inválida.' ]
  
  passwordChanged: (req, res) ->
    res.render 'passwordChanged'
  
  admin: (req, res) ->
    return res.redirect 'notseller' unless req.user.isSeller
    req.user.populate 'stores', (err, user) ->
      res.render 'admin', stores: user.stores
  
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
  
  index: (req, res) ->
    Product.find (err, products) ->
      dealWith err
      viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
      Store.findForHome (err, stores) ->
        dealWith err
        res.render "index", products: viewModelProducts, stores: stores
  
  store: (req, res) ->
    Store.findWithProductsBySlug req.params.storeSlug, (err, store, products) ->
      dealWith err
      return res.renderWithCode 404, 'storeNotFound', store: null, products: [] if store is null
      viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
      res.render "store", store: store, products: viewModelProducts, (err, html) ->
        #console.log html
        res.send html
  
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

module.exports = new Routes()
