AWS         = require 'aws-sdk'
fs          = require 'fs'
config      = require './config'
path        = require 'path'
os          = require 'os'
ImageManipulation = require './imageManipulation'

module.exports = class AmazonFileUploader
  constructor: ->
    AWS.config.update accessKeyId: config.aws.accessKeyId, secretAccessKey: config.aws.secretKey, region: config.aws.region
    @s3 = new AWS.S3()
    @bucket = config.aws.imagesBucket
    @tmpdir = os.tmpdir()
    @im = new ImageManipulation()
  upload: (fileName, file, dimensions, cb) ->
    @im.isSizeSmallerThan file.path, dimensions, (err, itIs) =>
      return cb err if err?
      return cb smallerThan: "O tamanho da imagem é menor do que o esperado, ela deve ter no mínimo #{dimensions}." if itIs
      @im.resizeAndCrop file.path, dimensions, (err, newFileName) =>
        fileParams = Bucket: @bucket, Key: fileName, Body: fs.createReadStream(newFileName), ContentType: file.type
        @s3.putObject fileParams, (err, data) =>
          return cb err if err?
          url = "https://s3.amazonaws.com/#{@bucket}/#{fileName}"
          cb null, url
          fs.unlink newFileName
  delete: (fileName, cb) ->
    key = fileName.replace "https://s3.amazonaws.com/#{@bucket}/", ""
    fileParams = Bucket: @bucket, Key: key
    @s3.deleteObject fileParams, (err, data) => cb err
  randomName: (folder, file) ->
    rand = -> Math.random() * Math.pow(10, 18)
    ext = path.extname file
    "#{folder}/#{rand()}#{rand()}#{ext}"
  thumbName: (fileName, dimensions) ->
    ext = path.extname fileName
    dir = path.dirname fileName
    name = path.basename fileName, ext
    "#{dir}/#{name}_thumb#{dimensions}#{ext}"
