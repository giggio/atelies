AWS         = require 'aws-sdk'
fs          = require 'fs'
path        = require 'path'
os          = require 'os'
Q           = require 'q'
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
  upload: (fileName, file, dimensions) ->
    if AmazonFileUploader.dryrun
      if !TEST then console.log "NOT uploading file, dry run"
      url = "https://s3.amazonaws.com/#{AmazonFileUploader.bucket}/#{fileName}"
      AmazonFileUploader.filesUploaded.push url
      return Q.fcall -> url
    AmazonFileUploader.im.isSizeSmallerThan file.path, dimensions
    .then (itIs) ->
      if itIs then throw smallerThan: "O tamanho da imagem é menor do que o esperado, ela deve ter no mínimo #{dimensions}."
      AmazonFileUploader.im.resizeAndCrop file.path, dimensions
    .then (newFileName) =>
      fileParams = Bucket: AmazonFileUploader.bucket, Key: fileName, Body: fs.createReadStream(newFileName), ContentType: file.headers['content-type']
      Q.ninvoke @s3, 'putObject', fileParams
      .then -> newFileName
    .then (newFileName) ->
      url = "https://s3.amazonaws.com/#{AmazonFileUploader.bucket}/#{fileName}"
      fs.unlink newFileName
      url
  delete: (fileName) ->
    key = fileName.replace "https://s3.amazonaws.com/#{AmazonFileUploader.bucket}/", ""
    fileParams = Bucket: AmazonFileUploader.bucket, Key: key
    Q.ninvoke @s3, 'deleteObject', fileParams
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
