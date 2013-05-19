mongoose = require 'mongoose'
slug     = require '../helpers/slug'

productSchema = new mongoose.Schema
  name:       type: String, required: true
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

productSchema.path('name').set (val) ->
  @slug = slug val.toLowerCase(), "_"
  val
productSchema.methods.url = -> "#{@storeSlug}##{@slug}"
productSchema.methods.manageUrl = -> "#{@storeSlug}/#{@_id}"
productSchema.methods.toSimpleProduct = ->
  _id: @_id, name: @name, picture: @picture, price: @price,
  storeName: @storeName, storeSlug: @storeSlug,
  url: @url(), tags: if @tags? then @tags.join ', ' else ''
  manageUrl: @manageUrl(), slug: @slug
  description: @description,
  height: @dimensions.height, width: @dimensions.width, depth: @dimensions.depth
  weight: @weight
  hasInventory: @hasInventory, inventory: @inventory
productSchema.methods.updateFromSimpleProduct = (simple) ->
  for attr in ['name', 'picture', 'price', 'description', 'weight', 'hasInventory', 'inventory']
    @[attr] = simple[attr]
  @tags = simple.tags?.split ','
  @dimensions = {} unless @dimensions?
  for attr in ['height', 'width', 'depth']
    @dimensions[attr] = simple[attr]

Product = mongoose.model 'product', productSchema
Product.findByStoreSlug = (storeSlug, cb) -> Product.find storeSlug: storeSlug, cb
Product.findByStoreSlugAndSlug = (storeSlug, productSlug, cb) -> Product.findOne {storeSlug: storeSlug, slug: productSlug}, cb

module.exports = Product
