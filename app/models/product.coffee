mongoose  = require 'mongoose'
slug      = require '../helpers/slug'
_         = require 'underscore'

productSchema = new mongoose.Schema
  name:           type: String, required: true
  nameKeywords:   [String]
  picture:        String
  price:          Number
  slug:           String
  storeName:      String
  storeSlug:      String
  tags:           [String]
  description:    String
  dimensions:
    height:       Number
    width:        Number
    depth:        Number
  weight:         Number
  shipping:
    dimensions:
      height:       Number
      width:        Number
      depth:        Number
    weight:         Number
  hasInventory:   Boolean
  inventory:      Number
  random:         type: Number, required: true, default: Math.random()

productSchema.path('name').set (val) ->
  @nameKeywords = if val is '' then [] else val.toLowerCase().split ' '
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
  height: @dimensions?.height, width: @dimensions?.width, depth: @dimensions?.depth
  weight: @weight
  shippingHeight: @shipping?.dimensions?.height, shippingWidth: @shipping?.dimensions?.width, shippingDepth: @shipping?.dimensions?.depth
  shippingWeight: @shipping?.weight
  hasInventory: @hasInventory, inventory: @inventory
productSchema.methods.toSimplerProduct = ->
  _id: @_id, name: @name, picture: @picture, price: @price,
  storeName: @storeName, storeSlug: @storeSlug,
  url: @url(), slug: @slug
productSchema.methods.updateFromSimpleProduct = (simple) ->
  for attr in ['name', 'price', 'description', 'weight', 'hasInventory', 'inventory']
    if simple[attr]? and simple[attr] isnt ''
      @[attr] = simple[attr]
    else
      @[attr] = undefined
  if simple.tags? and simple.tags isnt ''
    @tags = simple.tags?.split ','
  else
    @tags = []
  @dimensions = {} unless @dimensions?
  for attr in ['height', 'width', 'depth']
    if simple[attr]? and simple[attr] isnt ''
      @dimensions[attr] = simple[attr]
    else
      @dimensions[attr] = undefined
  @shipping = dimensions: {} unless @shipping?
  if simple.shippingHeight? and simple.shippingHeight isnt ''
    @shipping.dimensions.height = simple.shippingHeight
  else
    @shipping.dimensions.height = undefined
  if simple.shippingWidth? and simple.shippingWidth isnt ''
    @shipping.dimensions.width = simple.shippingWidth
  else
    @shipping.dimensions.width = undefined
  if simple.shippingDepth? and simple.shippingDepth isnt ''
    @shipping.dimensions.depth = simple.shippingDepth
  else
    @shipping.dimensions.depth = undefined
  if simple.shippingWeight? and simple.shippingWeight isnt ''
    @shipping.weight = simple.shippingWeight
  else
    @shipping.weight = undefined
productSchema.methods.hasShippingInfo = ->
  shipping = @shipping
  has = shipping.weight? and shipping.dimensions? and
  shipping.weight <= 30 and
  11 <= shipping.dimensions.width <= 105 and
  2 <= shipping.dimensions.height <= 105 and
  16 <= shipping.dimensions.depth <= 105 and
  shipping.dimensions.height + shipping.dimensions.width + shipping.dimensions.depth <= 200
  has

Product = mongoose.model 'product', productSchema
Product.findRandom = (howMany, cb) ->
  random = Math.random()
  Product.find({random:$gte:random}).sort('random').limit(howMany).exec (err, products) ->
    return cb err if err?
    if products.length > howMany / 2
      cb null, products
    else
      Product.find({random:$lte:random}).sort('random').limit(howMany).exec (err, products) ->
        return cb err if err?
        if products.length > howMany / 2
          cb null, products
        else
          Product.find().sort('random').limit(howMany).exec cb

Product.findByStoreSlug = (storeSlug, cb) -> Product.find storeSlug: storeSlug, cb
Product.findByStoreSlugAndSlug = (storeSlug, productSlug, cb) -> Product.findOne {storeSlug: storeSlug, slug: productSlug}, cb
Product.searchByName = (searchTerm, cb) ->
  Product.find nameKeywords:searchTerm.toLowerCase(), (err, products) ->
    return cb err if err
    cb null, products
Product.searchByStoreSlugAndByName = (storeSlug, searchTerm, cb) ->
  Product.find storeSlug: storeSlug, nameKeywords:searchTerm.toLowerCase(), (err, products) ->
    return cb err if err
    cb null, products
Product.getShippingWeightAndDimensions = (ids, cb) ->
  Product.find '_id': '$in': ids, '_id shipping', (err, products) ->
    cb err if err?
    cb null, products
Product.pictureDimension = '600x600'
Product.pictureThumbDimension = '150x150'

module.exports = Product
