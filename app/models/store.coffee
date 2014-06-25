mongoose = require 'mongoose'
async    = require 'async'
slug     = require '../helpers/slug'
_        = require 'underscore'
Evaluation = require './storeEvaluation'
Postman  = require './postman'
postman = new Postman()
Q         = require 'q'

storeSchema = new mongoose.Schema
  name:                   type: String, required: true
  nameKeywords:           [String]
  slug:                   String
  email:                  String
  description:            String
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
    paypal:
      clientId:           String
      secret:             String
  random:                 type: Number, required: true, default: -> Math.random()
  numberOfEvaluations:    type: Number, required: true, default: 0
  evaluationAvgRating:    type: Number, required: true, default: 0
  isFlyerAuthorized:      Boolean
  categories:             [ String ]

storeSchema.methods._isTheOnlyProduct = (product, simple) ->
  if product.name is simple.name then return Q.fcall ->
  Product.findByStoreSlugAndSlug @slug, slug(simple.name.toLowerCase(), "_")
  .then (existingProduct) -> if existingProduct? then throw nameExists: "Name '#{simple.name}' already exists."

storeSchema.methods.createProduct = (simple) ->
  product = new Product()
  product.storeName = @name
  product.storeSlug = @slug
  @updateProduct product, simple

storeSchema.methods.updateProduct = (product, simple) ->
  @_isTheOnlyProduct product, simple
  .then =>
    product.updateFromSimpleProduct simple
    @addCategories product.categories
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
  store.paypal = @paypal()
  store
storeSchema.methods.toSimpler = ->
  store =
    _id: @_id
    name: @name
    slug: @slug
    flyer: @flyer
  store.pagseguro = @pagseguro()
  store.paypal = @paypal()
  store
storeSchema.methods.pagseguro = -> @pmtGateways.pagseguro?.token? and @pmtGateways.pagseguro?.email?
storeSchema.methods.paypal = -> @pmtGateways.paypal?.clientId? and @pmtGateways.paypal?.secret?
storeSchema.path('name').set (val) ->
  @nameKeywords = if val is '' then [] else val.toLowerCase().split ' '
  @slug = slug val.toLowerCase(), "_"
  val
storeSchema.methods.setPagseguro = (set) ->
  if typeof set is 'boolean' and set is false
    @pmtGateways.pagseguro = undefined
  else
    @pmtGateways.pagseguro = set
storeSchema.methods.setPaypal = (set) ->
  if typeof set is 'boolean' and set is false
    @pmtGateways.paypal = undefined
  else
    @pmtGateways.paypal = set
storeSchema.methods.updateFromSimple = (simple) ->
  for attr in [ 'email', 'description', 'urlFacebook', 'urlTwitter', 'phoneNumber', 'city', 'state', 'zip', 'otherUrl' ]
    if simple[attr]? and simple[attr] isnt ''
      @[attr] = simple[attr]
    else
      @[attr] = undefined
storeSchema.methods.updateName = (name) ->
  currentSlug = @slug
  @name = name
  Q.ninvoke @, 'save'
  .then -> Product.findByStoreSlug currentSlug
  .then (products) =>
    saves = for p in products
      p.storeSlug = @slug
      p.storeName = name
      Q.ninvoke p, 'save'
    Q.all(saves).then => @
storeSchema.methods.sendMailAfterFlyerAuthorization = (userAuthorizing) ->
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
  User.findAdminsFor @_id
  .then (users) =>
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
          postman.sendFromContact user, "Ateliês: A loja #{@name} teve seu flyer #{status}", body
    Q.allSettled sendMailActions

module.exports = Store = mongoose.model 'store', storeSchema

Store.nameExists = (name) ->
  aSlug = slug name.toLowerCase(), "_"
  Store.findBySlug(aSlug).then (store) -> store?
Store.findBySlug = (slug, cb) -> callbackOrPromise cb, Q.ninvoke Store, 'findOne', slug: slug
Store.findSimpleByFlyerAuthorization = (isFlyerAuthorized, cb) ->
  Store.find isFlyerAuthorized: isFlyerAuthorized, flyer: /./, (err, stores) ->
    return cb err if err?
    cb null, _.map stores, (s) -> s.toSimple()
Store.findWithProductsBySlug = (slug) ->
  Store.findBySlug slug
  .then (store) ->
    return [null, null] unless store?
    Product.findByStoreSlug slug
    .then (products) -> [store, products]
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

Store.searchByName = (searchTerm) -> Q Store.find(nameKeywords: ///^#{searchTerm}///i).exec()
Store.flyerDimension = '350x350'
Store.ordersPerStore = ->
  Q.ninvoke Order, "mapReduce",
    map: -> emit @store, 1
    reduce: (key, values) -> Array.sum values
  .spread (res, stats) -> res
Store.productsPerStore = ->
  Q.ninvoke Product, "mapReduce",
    map: -> emit @storeSlug, 1
    reduce: (key, values) -> Array.sum values
  .spread (res, stats) -> res

Product  = require './product'
User     = require './user'
Order    = require './order'
