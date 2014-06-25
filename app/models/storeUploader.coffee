Store           = require '../models/store'
FileUploader    = require '../helpers/amazonFileUploader'
Q               = require 'q'

module.exports = class StoreUploader
  constructor: (@store) -> @uploader = new FileUploader()
  upload: (files, fields) ->
    unless files? then return Q.fcall ->
    actions = {}
    promises = []
    for field, dimensions of fields
      actions[field] = @_createPromise files[field], field, dimensions
      promises.push actions[field]
    Q.all promises
    .then ->
      for field, promise of actions
        actions[field] = promise.valueOf()
      actions
  _createPromise: (file, field, dimensionResize) ->
    unless file? then return Q.fcall ->
    onlineName = if @store[field]?
      @uploader.getFileNameFromFullName @store[field]
    else
      @uploader.randomName "#{@store.slug}/store", file.name
    @uploader.upload onlineName, file, dimensionResize
