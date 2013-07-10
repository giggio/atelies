mongoose = require 'mongoose'
Product  = require './product'
slug     = require '../helpers/slug'
_        = require 'underscore'

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
  zip:                    type: String, required: true
  otherUrl:               String
  banner:                 String
  flyer:                  String
  autoCalculateShipping:  Boolean
  pmtGateways:
    pagseguro:
      email:              String
      token:              String

storeSchema.methods.toSimple = ->
  store =
    _id: @_id
    name: @name
    slug: @slug
    email: @email
    description: @description
    homePageDescription: @homePageDescription
    homePageImage: @homePageImage
    urlFacebook: @urlFacebook
    urlTwitter: @urlTwitter
    phoneNumber: @phoneNumber
    city: @city
    state: @state
    zip: @zip
    otherUrl: @otherUrl
    banner: @banner
    flyer: @flyer
    autoCalculateShipping: @autoCalculateShipping
  store.pagseguro = @pagseguro()
  store
storeSchema.methods.toSimpler = ->
  store =
    _id: @_id
    name: @name
    slug: @slug
    homePageImage: @homePageImage
  store.pagseguro = @pagseguro()
  store
storeSchema.methods.pagseguro = -> @pmtGateways.pagseguro?.token? and @pmtGateways.pagseguro?.email?
storeSchema.path('name').set (val) ->
  @nameKeywords = if val is '' then [] else val.toLowerCase().split ' '
  @slug = slug val.toLowerCase(), "_"
  val
storeSchema.methods.setAutoCalculateShipping = (val, cb) ->
  unless val
    @autoCalculateShipping = false
    setImmediate => cb true
    return
  Product.findByStoreSlug @slug, (err, products) =>
    productWithMissingInfo = _.find products, (p) -> p.hasShippingInfo() is false
    @autoCalculateShipping = true unless productWithMissingInfo?
    cb not productWithMissingInfo?
storeSchema.methods.setPagseguro = (set) ->
  if typeof set is 'boolean' and set is false
    @pmtGateways.pagseguro = undefined
  else
    @pmtGateways.pagseguro = set

Store = mongoose.model 'store', storeSchema
Store.findBySlug = (slug, cb) -> Store.findOne slug: slug, cb
Store.findWithProductsBySlug = (slug, cb) ->
  Store.findBySlug slug, (err, store) ->
    return cb err if err
    return cb(null, null) if store is null
    Product.findByStoreSlug slug, (err, products) ->
      return cb err if err
      cb null, store, products
Store.findWithProductsById = (_id, cb) ->
  Store.findById _id, (err, store) ->
    return cb err if err
    return cb(null, null) if store is null
    Product.findByStoreSlug store.slug, (err, products) ->
      return cb err if err
      cb null, store, products
Store.findForHome = (cb) -> Store.find flyer: /./, cb
Store.searchByName = (searchTerm, cb) ->
  Store.find nameKeywords:searchTerm.toLowerCase(), (err, stores) ->
    return cb err if err
    cb null, stores

module.exports = Store
