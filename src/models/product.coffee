mongoose = require 'mongoose'

productSchema = new mongoose.Schema
  name:       String
  picture:    String
  price:      Number
  slug:       String
  storeName:  String
  storeSlug:  String

productSchema.methods.url = -> "#{@storeSlug}##{@slug}"
productSchema.methods.toSimpleProduct = -> _id: @_id, name: @name, picture: @picture, price: @price, storeName: @storeName, storeSlug: @storeSlug, url: @url()

Product = mongoose.model 'product', productSchema
Product.findByStoreSlug = (storeSlug, cb) -> Product.find storeSlug: storeSlug, cb
Product.findByStoreSlugAndSlug = (storeSlug, productSlug, cb) -> Product.findOne {storeSlug: storeSlug, slug: productSlug}, cb

module.exports = Product
