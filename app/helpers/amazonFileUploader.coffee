AWS         = require 'aws-sdk'
fs          = require 'fs'
path        = require 'path'
os          = require 'os'
ImageManipulation = require './imageManipulation'

module.exports = class AmazonFileUploader
  @configure = (id, secret, region, bucket) ->
    unless @dryrun
      AWS.config.update accessKeyId: id, secretAccessKey: secret, region: region
      @bucket = bucket
      @im = new ImageManipulation()

  @classProperty 'dryrun',
    get: =>
      @_dryrun = off unless @_dryrun?
      @_dryrun
    set: (val) =>
      @_dryrun = val
      if val
        @bucket = 'dryrun'
        @filesUploaded = []

  constructor: ->
    @s3 = new AWS.S3()
  upload: (fileName, file, dimensions, cb) ->
    if AmazonFileUploader.dryrun
      console.log "NOT uploading file, dry run"
      url = "https://s3.amazonaws.com/#{AmazonFileUploader.bucket}/#{fileName}"
      AmazonFileUploader.filesUploaded.push url
      return cb null, url
    AmazonFileUploader.im.isSizeSmallerThan file.path, dimensions, (err, itIs) =>
      return cb err if err?
      return cb smallerThan: "O tamanho da imagem é menor do que o esperado, ela deve ter no mínimo #{dimensions}." if itIs
      AmazonFileUploader.im.resizeAndCrop file.path, dimensions, (err, newFileName) =>
        return cb err if err?
        fileParams = Bucket: AmazonFileUploader.bucket, Key: fileName, Body: fs.createReadStream(newFileName), ContentType: file.headers['content-type']
        @s3.putObject fileParams, (err, data) ->
          return cb err if err?
          url = "https://s3.amazonaws.com/#{AmazonFileUploader.bucket}/#{fileName}"
          cb null, url
          fs.unlink newFileName
  delete: (fileName, cb) ->
    key = fileName.replace "https://s3.amazonaws.com/#{AmazonFileUploader.bucket}/", ""
    fileParams = Bucket: AmazonFileUploader.bucket, Key: key
    @s3.deleteObject fileParams, (err, data) -> cb err
  getFileNameFromFullName: (fileName) ->
    key = fileName.replace "https://s3.amazonaws.com/#{AmazonFileUploader.bucket}/", ""
    key
  randomName: (folder, file) ->
    rand = -> Math.random() * Math.pow(10, 18)
    ext = path.extname file
    "#{folder}/#{rand()}#{rand()}#{ext}"
  thumbName: (fileName, dimensions) ->
    ext = path.extname fileName
    dir = path.dirname fileName
    name = path.basename fileName, ext
    "#{dir}/#{name}_thumb#{dimensions}#{ext}"
