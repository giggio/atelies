mongoose = require 'mongoose'
async    = require 'async'
slug     = require '../helpers/slug'
_        = require 'underscore'
Evaluation = require './storeEvaluation'
Postman  = require './postman'
postman = new Postman()

storeSchema = new mongoose.Schema
  name:                   type: String, required: true
  nameKeywords:           [String]
  slug:                   String
  email:                  String
  description:            String
  homePageDescription:    String
  homePageImage:          String
  urlFacebook:            String
  urlTwitter:             String
  phoneNumber:            String
  city:                   type: String, required: true
  state:                  type: String, required: true
  zip:                    type: String, required: true
  otherUrl:               String
  banner:                 String
  flyer:                  String
  pmtGateways:
    pagseguro:
      email:              String
      token:              String
  random:                 type: Number, required: true, default: -> Math.random()
  numberOfEvaluations:    type: Number, required: true, default: 0
  evaluationAvgRating:    type: Number, required: true, default: 0
  isFlyerAuthorized:      Boolean
  categories:             [ String ]

storeSchema.methods.createProduct = (simple) ->
  product = new Product()
  product.storeName = @name
  product.storeSlug = @slug
  @updateProduct product, simple

storeSchema.methods.updateProduct = (product, simple) ->
  simple.hasInventory = false unless simple.hasInventory?
  for attr in ['name', 'price', 'description', 'weight', 'hasInventory', 'inventory']
    if simple[attr]? and simple[attr] isnt ''
      product[attr] = simple[attr]
    else
      product[attr] = undefined
  if simple.tags? and simple.tags isnt ''
    product.tags = simple.tags.match /(?=\S)[^,]+?(?=\s*(,|$))/g
  else
    product.tags = []
  product.dimensions = {} unless product.dimensions?
  for attr in ['height', 'width', 'depth']
    if simple[attr]? and simple[attr] isnt ''
      product.dimensions[attr] = simple[attr]
    else
      product.dimensions[attr] = undefined
  product.shipping = dimensions: {} unless product.shipping?
  if simple.shippingHeight? and simple.shippingHeight isnt ''
    product.shipping.dimensions.height = simple.shippingHeight
  else
    product.shipping.dimensions.height = undefined
  if simple.shippingWidth? and simple.shippingWidth isnt ''
    product.shipping.dimensions.width = simple.shippingWidth
  else
    product.shipping.dimensions.width = undefined
  if simple.shippingDepth? and simple.shippingDepth isnt ''
    product.shipping.dimensions.depth = simple.shippingDepth
  else
    product.shipping.dimensions.depth = undefined
  if simple.shippingWeight? and simple.shippingWeight isnt ''
    product.shipping.weight = simple.shippingWeight
  else
    product.shipping.weight = undefined
  product.shipping.applies = !!simple.shippingApplies
  product.shipping.charge = !!simple.shippingCharge
  if simple.categories? and simple.categories isnt ''
    product.categories = simple.categories.match /(?=\S)[^,]+?(?=\s*(,|$))/g
    @addCategories product.categories
  else
    product.categories = []
  product

storeSchema.methods.addCategories = (categoryNames) ->
  newCategoryNames = _.reject categoryNames, (categoryName) => categoryName in @categories
  @categories.push newCategoryNames...

storeSchema.methods.evaluationAdded = (evaluation) ->
  @evaluationAvgRating = ( @evaluationAvgRating * @numberOfEvaluations + evaluation.rating ) / ++@numberOfEvaluations
storeSchema.methods.toSimple = ->
  store =
    _id: @_id
    name: @name
    slug: @slug
    email: @email
    description: @description
    homePageDescription: @homePageDescription
    homePageImage: @homePageImage
    urlFacebook: @urlFacebook
    urlTwitter: @urlTwitter
    phoneNumber: @phoneNumber
    city: @city
    state: @state
    zip: @zip
    otherUrl: @otherUrl
    banner: @banner
    flyer: @flyer
    numberOfEvaluations: @numberOfEvaluations
    evaluationAvgRating: @evaluationAvgRating
    isFlyerAuthorized: @isFlyerAuthorized
    categories: @categories
  store.pagseguro = @pagseguro()
  store
storeSchema.methods.toSimpler = ->
  store =
    _id: @_id
    name: @name
    slug: @slug
    homePageImage: @homePageImage
    flyer: @flyer
  store.pagseguro = @pagseguro()
  store
storeSchema.methods.pagseguro = -> @pmtGateways.pagseguro?.token? and @pmtGateways.pagseguro?.email?
storeSchema.path('name').set (val) ->
  @nameKeywords = if val is '' then [] else val.toLowerCase().split ' '
  @slug = slug val.toLowerCase(), "_"
  val
storeSchema.methods.setPagseguro = (set) ->
  if typeof set is 'boolean' and set is false
    @pmtGateways.pagseguro = undefined
  else
    @pmtGateways.pagseguro = set
storeSchema.methods.updateFromSimple = (simple) ->
  for attr in [ 'email', 'description', 'homePageDescription', 'urlFacebook', 'urlTwitter', 'phoneNumber', 'city', 'state', 'zip', 'otherUrl' ]
    if simple[attr]? and simple[attr] isnt ''
      @[attr] = simple[attr]
    else
      @[attr] = undefined
storeSchema.methods.updateName = (name, cb) ->
  currentSlug = @slug
  @name = name
  @save()
  Product.findByStoreSlug currentSlug, (err, products) =>
    return cb err if err?
    for p in products
      p.storeSlug = @slug
      p.storeName = name
      p.save()
    cb()
storeSchema.methods.sendMailAfterFlyerAuthorization = (userAuthorizing, cb) ->
  if @isFlyerAuthorized
    status = "aprovado"
    unauthorizedMsg = ""
  else
    status = "reprovado"
    unauthorizedMsg = "<div>Quando o flyer de uma loja é reprovado a loja não aparece
      mais na home page do Ateliês (mas ainda aparece nas buscas).</div>
      <div>Para que sua loja apareça você deve colocar um arquivo que represente sua identidade visual e
      contenha o nome do seu ateliê de maneira legível, este arquivo será aprovado em até 48 horas por um
      administrador do portal.</div>
      <div>Você também pode falar com o administrador que reprovou o flyer diretamente.</div>"
  User.findAdminsFor @_id, (err, users) =>
    return cb err if err?
    sendMailActions =
      for user in users
        do (user) =>
          body = "<html>
            <h1>Olá #{user.name},</h1>
            <h2>O flyer da sua loja foi avaliado e foi #{status}.</h2>
            <div>
            </div>
            <div>O usuário que realizou a ação foi <a href='mailto:#{userAuthorizing.email}'>#{userAuthorizing.name}</a>.</div>
            <div></div>
            #{unauthorizedMsg}
            <div></div>
            <div></div>
            <div>Equipe Ateliês</div>
            </html>"
          (cb) => postman.sendFromContact user, "Ateliês: A loja #{@name} teve seu flyer #{status}", body, cb
    async.parallel sendMailActions, cb

module.exports = Store = mongoose.model 'store', storeSchema

Store.nameExists = (name, cb) ->
  aSlug = slug name.toLowerCase(), "_"
  Store.findBySlug aSlug, (err, store) -> cb err, store?
Store.findBySlug = (slug, cb) -> Store.findOne slug: slug, cb
Store.findSimpleByFlyerAuthorization = (isFlyerAuthorized, cb) ->
  Store.find isFlyerAuthorized: isFlyerAuthorized, flyer: /./, (err, stores) ->
    return cb err if err?
    cb null, _.map stores, (s) -> s.toSimple()
Store.findWithProductsBySlug = (slug, cb) ->
  Store.findBySlug slug, (err, store) =>
    return cb err if err?
    return cb(null, null) if store is null
    Product.findByStoreSlug slug, (err, products) ->
      return cb err if err?
      cb null, store, products
Store.findWithProductsById = (_id, cb) ->
  Store.findById _id, (err, store) ->
    return cb err if err?
    return cb(null, null) if store is null
    Product.findByStoreSlug store.slug, (err, products) ->
      return cb err if err?
      cb null, store, products
Store.findRandomForHome = (howMany, cb) ->
  random = Math.random()
  Store.find({flyer: /./, isFlyerAuthorized: true, random:$gte:random}).sort('random').limit(howMany).exec (err, stores) ->
    return cb err if err?
    if stores.length < howMany
      difference = stores.length - howMany
      Store.find({flyer: /./, isFlyerAuthorized: true}).sort('random').limit(difference).exec (err, newStores) ->
        return cb err if err?
        cb null, stores.concat newStores
    else
      cb null, stores

Store.searchByName = (searchTerm, cb) ->
  Store.find nameKeywords:searchTerm.toLowerCase(), (err, stores) ->
    return cb err if err?
    cb null, stores
Store.homePageImageDimension = '600x400'
Store.flyerDimension = '350x350'
#Store.bannerDimension = '1200x300'

Product  = require './product'
User  = require './user'
