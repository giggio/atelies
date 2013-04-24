Product     = require '../models/product'
Store       = require '../models/store'
_           = require 'underscore'

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
    res.render "store", store: store, products: viewModelProducts

exports.product = (req, res) ->
  #console.log "********request received for store slug: #{req.params.storeSlug} and productSlug #{req.params.productSlug}"
  Product.findByStoreSlugAndSlug req.params.storeSlug, req.params.productSlug, (err, product) ->
    dealWith err
    return res.send 404 if product is null
    res.json product.toSimpleProduct()
