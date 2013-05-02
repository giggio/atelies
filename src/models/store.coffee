mongoose = require 'mongoose'
Product  = require './product'
slug     = require 'slug'

storeSchema = new mongoose.Schema
  name:         type: String, required: true
  slug:         String
  phoneNumber:  String
  city:         type: String, required: true
  state:        type: String, required: true
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
Store.create = (o) =>
  store = new Store name: o.name, phoneNumber: o.phoneNumber, city: o.city, state: o.state, otherUrl: o.otherUrl, banner: o.banner
  store.slug = slug store.name.toLowerCase(), "_"
  store

module.exports = Store
