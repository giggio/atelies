Product         = require '../models/product'
FileUploader    = require '../helpers/amazonFileUploader'

module.exports = class ProductUploader
  upload: (product, file, cb) ->
    if file?
      uploader = new FileUploader()
      if product.picture?
        onlineName = uploader.getFileNameFromFullName product.picture
      else
        onlineName = uploader.randomName "#{product.storeSlug}/products", file.name
      uploader.upload onlineName, file, Product.pictureDimension, (err, fileUrl) ->
        return cb err if err?
        thumbOnlineName = uploader.thumbName onlineName, Product.pictureThumbDimension
        uploader.upload thumbOnlineName, file, Product.pictureThumbDimension, (err, thumbUrl) ->
          return cb err if err?
          cb null, fileUrl
    else
      setImmediate cb
