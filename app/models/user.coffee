mongoose  = require 'mongoose'
_         = require 'underscore'
Store     = require './store'

userSchema = new mongoose.Schema
  name:         type: String, required: true
  email:        type: String, required: true
  passwordHash: type: String, required: true
  isSeller:     type: Boolean, default: false
  stores:       [{type: mongoose.Schema.Types.ObjectId, ref: 'store'}]

userSchema.methods.createStore = ->
  store = new Store()
  @stores.push store
  store
userSchema.methods.hasStore = (store) ->
  storeFound = _.find @stores, (_id) -> store._id.toString() is _id.toString()
  storeFound?
User = mongoose.model 'user', userSchema
User.findByEmail = (email, cb) -> User.findOne email: email, cb

module.exports = User
