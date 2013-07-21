im          = require('gm').subClass imageMagick:on
os          = require 'os'
path        = require 'path'
module.exports = class ImageManipulation
  constructor: ->
    @tmpdir = os.tmpdir()
  resize: (filePath, dimensions, cb) ->
    return setImmediate(-> cb null, filePath) unless dimensions?
    tempName = @_tempRandomName filePath
    d = @_getDimensions dimensions
    im(filePath).resize(d.width, d.height, "^").quality(90).write tempName, (err) -> cb err, tempName
  _tempRandomName: (file) ->
    rand = -> Math.random() * Math.pow(10, 18)
    ext = path.extname file
    path.join @tmpdir, "#{rand()}#{rand()}#{ext}"
  resizeAndCrop: (filePath, dimensions, cb) ->
    return setImmediate(-> cb null, filePath) unless dimensions?
    tempName = @_tempRandomName filePath
    d = @_getDimensions dimensions
    im(filePath).resize(d.width, d.height, "^").crop(d.width, d.height, 0, 0).quality(90).write tempName, (err) -> cb err, tempName
  _getDimensions: (dimensions) ->
    width: parseInt dimensions.substr 0, dimensions.indexOf 'x'
    height: parseInt dimensions.substr dimensions.indexOf('x') + 1
  getSize: (filePath, cb) -> im(filePath).size cb
  isSizeSmallerThan: (filePath, dimensions, cb) ->
    return setImmediate(-> cb null, false) unless dimensions?
    @getSize filePath, (err, size) =>
      return cb err if err?
      expectedDimensions = @_getDimensions dimensions
      cb null, size.width < expectedDimensions.width or size.height < expectedDimensions.height
