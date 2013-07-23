Store           = require '../models/store'
FileUploader    = require '../helpers/amazonFileUploader'
async           = require 'async'

module.exports = class StoreUploader
  constructor: (@store) ->
    @uploader = new FileUploader()
  upload: (files, fields, cb) ->
    return setImmediate cb unless files?
    actions = {}
    for field, dimensions of fields
      actions[field] = @_createAction files[field], field, dimensions
    async.parallel actions, cb
  _createAction: (file, field, dimensionResize) ->
    (cb) =>
      return cb() unless file?
      if @store[field]?
        onlineName = @uploader.getFileNameFromFullName @store[field]
      else
        onlineName = @uploader.randomName "#{@store.slug}/store", file.name
      @uploader.upload onlineName, file, dimensionResize, (err, fileUrl) ->
        return cb err if err?
        cb null, fileUrl
