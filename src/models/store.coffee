mongoose = require 'mongoose'

storeSchema = new mongoose.Schema
  name:       String
  slug:       String

Store = mongoose.model 'store', storeSchema
module.exports = Store
