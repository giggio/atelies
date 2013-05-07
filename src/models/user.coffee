mongoose  = require 'mongoose'
Store     = require './store'

userSchema = new mongoose.Schema
  name:         type: String, required: true
  email:        type: String, required: true
  password:     type: String, required: true
  isSeller:     type: Boolean, default: false
  stores:       [{type: mongoose.Schema.Types.ObjectId, ref: 'store'}]

userSchema.methods.createStore = ->
  store = new Store()
  @stores.push store
  store
User = mongoose.model 'user', userSchema
User.findByEmail = (email, cb) -> User.findOne email: email, cb

module.exports = User
