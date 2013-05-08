mongoose = require 'mongoose'

productSchema = new mongoose.Schema
  name:       String
  picture:    String
  price:      Number
  slug:       String
  storeName:  String
  storeSlug:  String
  tags: [String]
  description: String
  dimensions:
    height: Number
    width: Number
    depth: Number
  weight: Number
  hasInventory: Boolean
  inventory: Number

productSchema.methods.url = -> "#{@storeSlug}##{@slug}"
productSchema.methods.manageUrl = -> "#{@storeSlug}/#{@slug}"
productSchema.methods.toSimpleProduct = ->
  _id: @_id, name: @name, picture: @picture, price: @price,
  storeName: @storeName, storeSlug: @storeSlug,
  url: @url(), tags: @tags.join ', '
  manageUrl: @manageUrl()
  description: @description, dimensions: @dimensions, weight: @weight
  hasInventory: @hasInventory, inventory: @inventory

Product = mongoose.model 'product', productSchema
Product.findByStoreSlug = (storeSlug, cb) -> Product.find storeSlug: storeSlug, cb
Product.findByStoreSlugAndSlug = (storeSlug, productSlug, cb) -> Product.findOne {storeSlug: storeSlug, slug: productSlug}, cb

module.exports = Product
