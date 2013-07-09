mongoose  = require 'mongoose'
_         = require 'underscore'
Store     = require './store'

userSchema = new mongoose.Schema
  name:             type: String, required: true
  email:            type: String, required: true
  passwordHash:     type: String, required: true
  isSeller:         type: Boolean, default: false
  stores:           [{type: mongoose.Schema.Types.ObjectId, ref: 'store'}]
  deliveryAddress:
    street:         String
    street2:        String
    city:           String
    state:          String
    zip:            String
  phoneNumber:    String

userSchema.methods.createStore = ->
  store = new Store()
  @stores.push store
  store
userSchema.methods.hasStore = (store) ->
  if store._id?
    id = store._id.toString()
  else
    id = store.toString()
  storeFound = _.find @stores, (_id) -> id is _id.toString()
  storeFound?
userSchema.methods.verifyPassword = (passwordToVerify, cb) ->
  bcrypt = require 'bcrypt'
  bcrypt.compare passwordToVerify, @passwordHash, cb
userSchema.methods.setPassword = (password) ->
  bcrypt = require 'bcrypt'
  salt = bcrypt.genSaltSync 10
  @passwordHash = bcrypt.hashSync password, salt
userSchema.methods.toSimpleUser = ->
  _id: @_id
  name: @name
  email: @email
  deliveryAddress: @deliveryAddress
  phoneNumber: @phoneNumber
  
User = mongoose.model 'user', userSchema
User.findByEmail = (email, cb) -> User.findOne email: email, cb

module.exports = User
