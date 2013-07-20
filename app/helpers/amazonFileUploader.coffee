AWS         = require 'aws-sdk'
fs          = require 'fs'
config      = require './config'
path        = require 'path'

module.exports = class AmazonFileUploader
  constructor: ->
    AWS.config.update accessKeyId: config.aws.accessKeyId, secretAccessKey: config.aws.secretKey, region: config.aws.region
    @s3 = new AWS.S3()
    @bucket = config.aws.imagesBucket
  upload: (fileName, file, cb) ->
    fileParams = Bucket: @bucket, Key: fileName, Body: fs.createReadStream(file.path), ContentType: file.type
    @s3.putObject fileParams, (err, data) =>
      return cb err if err?
      url = "https://s3.amazonaws.com/#{@bucket}/#{fileName}"
      cb null, url
  delete: (fileName, cb) ->
    key = fileName.replace "https://s3.amazonaws.com/#{@bucket}/", ""
    fileParams = Bucket: @bucket, Key: key
    @s3.deleteObject fileParams, (err, data) => cb err

  randomName: (folder, file) ->
    rand = -> Math.random() * Math.pow(10, 17)
    ext = path.extname file
    "#{folder}/#{rand()}#{rand()}#{ext}"
