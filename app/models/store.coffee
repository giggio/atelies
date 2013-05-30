mongoose = require 'mongoose'
Product  = require './product'
slug     = require '../helpers/slug'

storeSchema = new mongoose.Schema
  name:                   type: String, required: true
  nameKeywords:           [String]
  slug:                   String
  email:                  String
  description:            String
  homePageDescription:    String
  homePageImage:          String
  urlFacebook:            String
  urlTwitter:             String
  phoneNumber:            String
  city:                   type: String, required: true
  state:                  type: String, required: true
  otherUrl:               String
  banner:                 String
  flyer:                  String

storeSchema.path('name').set (val) ->
  @nameKeywords = if val is '' then [] else val.toLowerCase().split ' '
  @slug = slug val.toLowerCase(), "_"
  val

Store = mongoose.model 'store', storeSchema
Store.findBySlug = (slug, cb) -> Store.findOne slug: slug, cb
Store.findWithProductsBySlug = (slug, cb) ->
  Store.findBySlug slug, (err, store) ->
    return cb err if err
    return cb(null, null) if store is null
    Product.findByStoreSlug slug, (err, products) ->
      return cb err if err
      cb null, store, products
Store.findForHome = (cb) -> Store.find flyer: /./, cb
Store.searchByName = (searchTerm, cb) ->
  Store.find nameKeywords:searchTerm.toLowerCase(), (err, stores) ->
    return cb err if err
    cb null, stores

module.exports = Store
