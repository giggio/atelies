mongoose    = require 'mongoose'
Product     = require '../models/product'
Store       = require '../models/store'
_           = require 'underscore'

exports.index = (req, res) ->
  Product.find (err, products) ->
    dealWith err
    viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
    res.render "index", products: viewModelProducts

exports.store = (req, res) ->
  Store.findOne slug: req.params.storeSlug, (err, store) ->
    dealWith err
    return res.renderWithCode 404, 'store', store: null, products: [] if store is null
    Product.find storeSlug: req.params.storeSlug, (err, products) ->
      dealWith err
      viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
      res.render "store", store: store, products: viewModelProducts

exports.product = (req, res) ->
  Product.findOne {storeSlug: req.params.storeSlug, slug: req.params.productSlug}, (err, product) ->
    dealWith err
    return res.send 404 if product is null
    viewModelProduct = product.toSimpleProduct()
    res.json viewModelProduct
