mongoose = require 'mongoose'

userSchema = new mongoose.Schema
  name:         type: String, required: true
  email:        type: String, required: true
  password:     type: String, required: true
  isSeller:     type: Boolean, default: false

User = mongoose.model 'user', userSchema
User.findByEmail = (email, cb) -> User.findOne email: email, cb

module.exports = User
