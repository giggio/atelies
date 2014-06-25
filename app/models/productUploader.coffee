Product         = require '../models/product'
FileUploader    = require '../helpers/amazonFileUploader'
Q               = require 'q'

module.exports = class ProductUploader
  upload: (product, file) ->
    unless file? then return Q.fcall ->
    uploader = new FileUploader()
    onlineName = if product.picture?
      uploader.getFileNameFromFullName product.picture
    else
      uploader.randomName "#{product.storeSlug}/products", file.name
    uploader.upload onlineName, file, Product.pictureDimension
    .then (fileUrl) ->
      thumbOnlineName = uploader.thumbName onlineName, Product.pictureThumbDimension
      uploader.upload thumbOnlineName, file, Product.pictureThumbDimension
      .then (thumbUrl) -> fileUrl
