mongoose    = require 'mongoose'
Product     = require '../models/product'
Store       = require '../models/store'
_           = require 'underscore'

exports.index = (req, res) ->
  mongoose.connect process.env.CUSTOMCONNSTR_mongo
  mongoose.connection.on 'error', (err) ->
    console.error "connection error:#{err.stack}"
    throw err
  mongoose.connection.once 'open', ->
    Product.find (err, products) ->
      if err
        console.error err.stack
        throw err
      viewModelProducts = _.map products, (p) -> {_id: p._id, name: p.name, picture: p.picture, price: p.price, storeName: p.storeName, storeSlug: p.storeSlug, url: p.url()}
      res.render "index", products: viewModelProducts
      mongoose.connection.close()
      mongoose.disconnect()

exports.store = (req, res) ->
  mongoose.connect process.env.CUSTOMCONNSTR_mongo
  mongoose.connection.on 'error', (err) ->
    console.error "connection error:#{err.stack}"
    throw err
  mongoose.connection.once 'open', ->
    Store.findOne slug: req.params.storeSlug, (err, store) ->
      if err
        console.error err.stack
        throw err
      if store is null
        res.status 404
        res.render 'store', store: null, products: []
        mongoose.connection.close()
        mongoose.disconnect()
        return
      Product.find storeSlug: req.params.storeSlug, (err, products) ->
        if err
          console.error err.stack
          throw err
        viewModelProducts = _.map products, (p) -> {_id: p._id, name: p.name, picture: p.picture, price: p.price, storeName: p.storeName, storeSlug: p.storeSlug, url: p.url()}
        #res.render "store", store: {name: req.params.storeSlug, slug: req.params.storeSlug, products: [{_id: '1', name: 'prod 1', url: 'store1#prod_1', picture: 'http://lorempixel.com/50/50/cats', }]}
        res.render "store", store: store, products: viewModelProducts
        mongoose.connection.close()
        mongoose.disconnect()
