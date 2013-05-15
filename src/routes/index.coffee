Product         = require '../models/product'
Store           = require '../models/store'
_               = require 'underscore'
everyauth       = require 'everyauth'
AccessDenied    = require '../errors/accessDenied'

exports.admin = (req, res) ->
  unless req.loggedIn
    return res.redirect 'login'
  unless req.user.isSeller
    return res.redirect 'notseller'
  req.user.populate 'stores', (err, user) ->
    res.render 'admin', stores: user.stores

exports.notSeller = (req, res) -> res.render 'notseller'

exports.adminStore = (req, res) ->
  unless req.loggedIn and req.user?.isSeller
    throw new AccessDenied()
  store = req.user.createStore()
  store.name = req.body.name
  store.phoneNumber = req.body.phoneNumber
  store.city = req.body.city
  store.state = req.body.state
  store.otherUrl = req.body.otherUrl
  store.banner = req.body.banner
  store.save (err) ->
    return res.json 400, err if err?
    req.user.save (err) ->
      if err?
        store.remove()
        return res.json 400
      res.json 201, store

exports.index = (req, res) ->
  Product.find (err, products) ->
    dealWith err
    viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
    res.render "index", products: viewModelProducts

exports.store = (req, res) ->
  Store.findWithProductsBySlug req.params.storeSlug, (err, store, products) ->
    dealWith err
    return res.renderWithCode 404, 'store', store: null, products: [] if store is null
    viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
    res.render "store", store: store, products: viewModelProducts, (err, html) ->
      #console.log html
      res.send html

exports.storeProducts = (req, res) ->
  Product.findByStoreSlug req.params.storeSlug, (err, products) ->
    dealWith err
    viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
    res.json viewModelProducts

exports.adminProductUpdate = (req, res) ->
  unless req.loggedIn and req.user?.isSeller
    throw new AccessDenied()
  Product.findById req.params.productId, (err, product) ->
    dealWith err
    Store.findBySlug product.storeSlug, (err, store) ->
      dealWith err
      storeFromUser = _.find req.user.stores, (_id) -> store._id.toString() is _id.toString()
      unless storeFromUser?
        throw new AccessDenied()
      body = req.body
      for attr in ['name', 'picture', 'price', 'description', 'weight', 'hasInventory', 'inventory']
        product[attr] = body[attr]
      product.tags = body.tags.split ','
      product.dimensions = {} unless product.dimensions?
      for attr in ['height', 'width', 'depth']
        product.dimensions[attr] = body[attr]
      product.save (err) ->
        res.send 204

exports.storeProduct = (req, res) ->
  Product.findById req.params.productId, (err, product) ->
    dealWith err
    res.json product.toSimpleProduct()

exports.product = (req, res) ->
  Product.findByStoreSlugAndSlug req.params.storeSlug, req.params.productSlug, (err, product) ->
    dealWith err
    return res.send 404 if product is null
    res.json product.toSimpleProduct()
