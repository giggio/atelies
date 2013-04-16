mongoose = require 'mongoose'
Product  = require './product'

storeSchema = new mongoose.Schema
  name:         String
  slug:         String
  phoneNumber:  String
  city:         String
  state:        String
  otherUrl:     String
  banner:       String

Store = mongoose.model 'store', storeSchema
Store.findBySlug = (slug, cb) -> Store.findOne slug: slug, cb
Store.findWithProductsBySlug = (slug, cb) ->
  Store.findBySlug slug, (err, store) ->
    return cb err if err
    return cb(null, null) if store is null
    Product.findByStoreSlug slug, (err, products) ->
      return cb err if err
      cb null, store, products

module.exports = Store
