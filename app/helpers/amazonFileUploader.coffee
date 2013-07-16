AWS         = require 'aws-sdk'
fs          = require 'fs'

module.exports = class AmazonFileUploader
  upload: (fileName, file, cb) ->
    AWS.config.update accessKeyId: process.env.AWSAccessKeyId, secretAccessKey: process.env.AWSSecretKey, region: "us-east-1"
    s3 = new AWS.S3()
    fileParams = Bucket: 'atelies', Key: fileName, Body: fs.createReadStream(file.path)
    s3.putObject fileParams, (err, data) =>
      return cb err if err?
      url = "https://s3.amazonaws.com/atelies/#{fileName}"
      cb null, url
