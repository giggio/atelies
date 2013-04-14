mongoose = require 'mongoose'

productSchema = new mongoose.Schema
  name:       String
  picture:    String
  price:      Number
  slug:       String
  storeName:  String
  storeSlug:  String

productSchema.methods.url = -> "#{@storeSlug}/#{@slug}"

Product = mongoose.model 'product', productSchema
module.exports = Product
