mongoose  = require 'mongoose'
_         = require 'underscore'

errorSchema = new mongoose.Schema
  message:                    type: String, required: true
  stack:                      type: String, required: true
  path:                       type: String, required: true
  verb:                       type: String, required: true
  date:                       type: Date, required: true, default: Date.now
  client:                     type: Boolean, required: true, default: false #client js, or server js
  module:                     type: String, required: true #admin, account, store, home
  user:                       type: mongoose.Schema.Types.ObjectId, ref: 'user'
  otherInfo:                  String

ErrorModel = mongoose.model 'error', errorSchema
ErrorModel.create = (module, client, req, err, otherInfo) ->
  if err instanceof Error
    message = err.message
    stack = new Error().stack + "\nOriginal Error Stack:\n" + err.stack
  else
    message = if typeof err is 'string' then err else JSON.stringify err
    stack = new Error().stack
  error = new ErrorModel
    message: message
    stack: stack
    path: req.originalUrl
    verb: req.method
    client: client
    module: module
    user: req.user
    otherInfo: otherInfo
  error.save()
  error

module.exports = ErrorModel
