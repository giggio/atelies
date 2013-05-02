Product     = require '../models/product'
Store       = require '../models/store'
_           = require 'underscore'
slug        = require 'slug'

exports.admin = (req, res) ->
  res.render 'admin'

exports.adminStore = (req, res) ->
  store = new Store name: req.body.name, phoneNumber: req.body.phoneNumber, city: req.body.city, state: req.body.state, otherUrl: req.body.otherUrl, banner: req.body.banner
  store.set 'slug', slug store.name.toLowerCase(), "_"
  store.save (err) ->
    res.json store

exports.index = (req, res) ->
  Product.find (err, products) ->
    dealWith err
    viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
    res.render "index", products: viewModelProducts

exports.store = (req, res) ->
  #console.log "********request received for store slug: #{req.params.storeSlug}"
  Store.findWithProductsBySlug req.params.storeSlug, (err, store, products) ->
    dealWith err
    return res.renderWithCode 404, 'store', store: null, products: [] if store is null
    viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
    #console.log JSON.stringify store
    #console.log JSON.stringify viewModelProducts
    res.render "store", store: store, products: viewModelProducts, (err, html) ->
      #console.log html
      res.send html

exports.product = (req, res) ->
  #console.log "********request received for store slug: #{req.params.storeSlug} and productSlug #{req.params.productSlug}"
  Product.findByStoreSlugAndSlug req.params.storeSlug, req.params.productSlug, (err, product) ->
    dealWith err
    return res.send 404 if product is null
    res.json product.toSimpleProduct()
