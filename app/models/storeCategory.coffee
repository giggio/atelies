mongoose = require 'mongoose'

storeCategorySchema = new mongoose.Schema
  name:                   type: String, required: true

module.exports = StoreCategory = mongoose.model 'storecategory', storeCategorySchema
