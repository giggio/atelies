mongoose = require 'mongoose'

productSchema = new mongoose.Schema
  name:       String
  picture:    String
  price:      Number

Product = mongoose.model 'product', productSchema
module.exports = Product
