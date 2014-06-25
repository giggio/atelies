mongoose  = require 'mongoose'
slug      = require '../helpers/slug'
_         = require 'underscore'
path      = require 'path'
async     = require 'async'
Q         = require 'q'

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
    applies:      Boolean
    charge:       Boolean
    dimensions:
      height:     Number
      width:      Number
      depth:      Number
    weight:       Number
  hasInventory:   Boolean
  inventory:      Number
  random:         type: Number, required: true, default: -> Math.random()
  categories:     [ String ]

productSchema.path('name').set (val) ->
  @nameKeywords = if val is '' then [] else val.toLowerCase().split ' '
  @slug = slug val.toLowerCase(), "_"
  val
productSchema.methods.updateFromSimpleProduct = (simple) ->
  @[attr] = simple[attr] for attr in ['name', 'price', 'description', 'weight', 'hasInventory', 'inventory']
  @tags = simple.tags?.match(/(?=\S)[^,]+?(?=\s*(,|$))/g) || []
  @dimensions = {} unless @dimensions?
  @dimensions[attr] = simple[attr] for attr in ['height', 'width', 'depth']
  @shipping = dimensions: {} unless @shipping?
  @shipping.dimensions[attr] = simple["shipping#{attr.capitaliseFirstLetter()}"] for attr in ['height', 'width', 'depth']
  @shipping.weight = simple.shippingWeight
  @shipping.applies = !!simple.shippingApplies
  @shipping.charge = !!simple.shippingCharge
  @categories = simple.categories?.match(/(?=\S)[^,]+?(?=\s*(,|$))/g) || []
productSchema.methods.url = -> "#{@storeSlug}/#{@slug}"
productSchema.methods.addComment = (comment) ->
  comment.product = @
  ProductComment.create comment

productSchema.methods.findAdmins = ->
  Store.findBySlug @storeSlug
  .then (store) -> User.findAdminsFor store
productSchema.methods.manageUrl = -> "#{@storeSlug}/#{@_id}"
productSchema.methods.pictureThumb = ->
  return undefined unless @picture?
  ext = path.extname @picture
  dir = path.dirname @picture
  name = path.basename @picture, ext
  "#{dir}/#{name}_thumb150x150#{ext}"
productSchema.methods.toSimpleProduct = ->
  _id: @_id, name: @name, picture: @picture, pictureThumb: @pictureThumb(), price: @price,
  storeName: @storeName, storeSlug: @storeSlug,
  url: @url(), tags: if @tags? then @tags.join ',' else ''
  manageUrl: @manageUrl(), slug: @slug
  description: @description,
  height: @dimensions?.height, width: @dimensions?.width, depth: @dimensions?.depth
  weight: @weight
  shippingApplies: @shipping?.applies, shippingCharge: @shipping?.charge
  shippingHeight: @shipping?.dimensions?.height, shippingWidth: @shipping?.dimensions?.width, shippingDepth: @shipping?.dimensions?.depth
  shippingWeight: @shipping?.weight
  hasInventory: @hasInventory, inventory: @inventory
  categories: @categories.join ','
productSchema.methods.toSimpleProductWithComments = (cb) ->
  simple = @toSimpleProduct()
  Q.ninvoke ProductComment, 'findByProduct', @
  .then (comments) ->
    simple.comments = _.map comments, (c) -> c.toSimple()
    simple
productSchema.methods.toSimplerProduct = ->
  _id: @_id, name: @name, picture: @picture, pictureThumb: @pictureThumb(), price: @price,
  storeName: @storeName, storeSlug: @storeSlug,
  url: @url(), slug: @slug
  categories: @categories
productSchema.methods.hasShippingInfo = ->
  shipping = @shipping
  has = shipping.applies and
  shipping.weight? and shipping.dimensions? and
  shipping.weight <= 30 and
  11 <= shipping.dimensions.width <= 105 and
  2 <= shipping.dimensions.height <= 105 and
  16 <= shipping.dimensions.depth <= 105 and
  shipping.dimensions.height + shipping.dimensions.width + shipping.dimensions.depth <= 200
  has

module.exports = Product = mongoose.model 'product', productSchema

Product.findRandom = (howMany) ->
  random = Math.random()
  Q Product.find({picture: /./, random:$gte:random}).sort('random').limit(howMany).exec()
  .then (products) ->
    if products.length >= howMany
      products
    else
      difference = products.length - howMany
      Q Product.find(picture: /./).sort('random').limit(difference).exec()
      .then (newProducts) -> products.concat newProducts

Product.findByStoreSlug = (storeSlug, cb) -> callbackOrPromise cb, Q.ninvoke Product, "find", storeSlug: storeSlug
Product.findByStoreSlugAndSlug = (storeSlug, productSlug) -> Q.ninvoke Product, 'findOne', storeSlug: storeSlug, slug: productSlug
Product.searchByName = (searchTerm) -> Q Product.find(nameKeywords: ///^#{searchTerm}///i).exec()
Product.searchByTag = (searchTerm) -> Q Product.find(tags: ///^#{searchTerm}///i).exec()
Product.searchByCategory = (searchTerm) -> Q Product.find(categories: ///^#{searchTerm}///i).exec()
Product.searchByStoreSlugAndByName = (storeSlug, searchTerm) -> Q Product.find(storeSlug: storeSlug, nameKeywords: ///^#{searchTerm}///i).exec()
Product.getShippingWeightAndDimensions = (ids, cb) ->
  Product.find '_id': '$in': ids, '_id shipping', (err, products) ->
    cb err if err?
    cb null, products
Product.pictureDimension = '600x600'
Product.pictureThumbDimension = '150x150'

User                = require './user'
Store               = require './store'
ProductComment      = require './productComment'
