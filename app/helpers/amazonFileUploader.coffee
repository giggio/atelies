AWS         = require 'aws-sdk'
fs          = require 'fs'

module.exports = class AmazonFileUploader
  constructor: ->
    AWS.config.update accessKeyId: process.env.AWSAccessKeyId, secretAccessKey: process.env.AWSSecretKey, region: "us-east-1"
    @s3 = new AWS.S3()
  upload: (fileName, file, cb) ->
    fileParams = Bucket: 'atelies', Key: fileName, Body: fs.createReadStream(file.path)
    @s3.putObject fileParams, (err, data) =>
      return cb err if err?
      url = "https://s3.amazonaws.com/atelies/#{fileName}"
      cb null, url
  delete: (fileName, cb) ->
    key = fileName.replace "https://s3.amazonaws.com/atelies/", ""
    fileParams = Bucket: 'atelies', Key: key
    @s3.deleteObject fileParams, (err, data) => cb err
