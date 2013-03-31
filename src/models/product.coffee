mongoose = require 'mongoose'

productSchema = new mongoose.Schema
  name:       String
  picture:    String
  price:      Number

module.exports = mongoose.model 'product', productSchema
