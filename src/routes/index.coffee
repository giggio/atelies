mongoose    = require 'mongoose'
Product     = require '../models/product'
_           = require 'underscore'

exports.index = (req, res) ->
  mongoose.connect process.env.CUSTOMCONNSTR_mongo
  mongoose.connection.on 'error', (err) ->
    console.error "connection error:#{err.stack}"
    throw err
  mongoose.connection.once 'open', ->
    Product.find (err, products) ->
      console.error err.stack if err
      viewModelProducts = _.map products, (p) -> {_id: p._id, name: p.name, picture: p.picture, price: p.price, storeName: p.storeName, storeSlug: p.storeSlug, url: p.url()}
      res.render "index", products: viewModelProducts
      mongoose.connection.close()
      mongoose.disconnect()

exports.store = (req, res) ->
  res.render "store", storeSlug: req.params.storeSlug
