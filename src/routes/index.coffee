mongoose    = require 'mongoose'
Product     = require '../models/product'
Store       = require '../models/store'
_           = require 'underscore'

exports.index = (req, res) ->
  Product.find (err, products) ->
    if err
      console.error err.stack
      throw err
    viewModelProducts = _.map products, (p) -> {_id: p._id, name: p.name, picture: p.picture, price: p.price, storeName: p.storeName, storeSlug: p.storeSlug, url: p.url()}
    res.render "index", products: viewModelProducts

exports.store = (req, res) ->
  Store.findOne slug: req.params.storeSlug, (err, store) ->
    if err
      console.error err.stack
      throw err
    if store is null
      res.status 404
      res.render 'store', store: null, products: []
      return
    Product.find storeSlug: req.params.storeSlug, (err, products) ->
      if err
        console.error err.stack
        throw err
      viewModelProducts = _.map products, (p) -> {_id: p._id, name: p.name, picture: p.picture, price: p.price, storeName: p.storeName, storeSlug: p.storeSlug, url: p.url()}
      res.render "store", store: store, products: viewModelProducts

exports.product = (req, res) ->
  Product.findOne {storeSlug: req.params.storeSlug, slug: req.params.productSlug}, (err, p) ->
    if err
      console.error err.stack
      throw err
    if p is null
      return res.send 404

    viewModelProduct = {_id: p._id, name: p.name, picture: p.picture, price: p.price, storeName: p.storeName, storeSlug: p.storeSlug, url: p.url()}
    res.json viewModelProduct
