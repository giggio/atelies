im          = require('gm').subClass imageMagick:on
os          = require 'os'
path        = require 'path'
Q           = require 'q'

module.exports = class ImageManipulation
  constructor: ->
    @tmpdir = os.tmpdir()
  resize: (filePath, dimensions) ->
    unless dimensions? then return Q.fcall -> filePath
    tempName = @_tempRandomName filePath
    d = @_getDimensions dimensions
    Q.ninvoke im(filePath).resize(d.width, d.height, "^").quality(90), "write", tempName
    .then -> tempName
  _tempRandomName: (file) ->
    rand = -> Math.random() * Math.pow(10, 18)
    ext = path.extname file
    path.join @tmpdir, "#{rand()}#{rand()}#{ext}"
  resizeAndCrop: (filePath, dimensions) ->
    if !dimensions? then return Q.fcall -> filePath
    tempName = @_tempRandomName filePath
    d = @_getDimensions dimensions
    Q.ninvoke im(filePath).resize(d.width, d.height, "^").crop(d.width, d.height, 0, 0).quality(90), 'write', tempName
    .then -> tempName
  _getDimensions: (dimensions) ->
    width: parseInt dimensions.substr 0, dimensions.indexOf 'x'
    height: parseInt dimensions.substr dimensions.indexOf('x') + 1
  getSize: (filePath) -> Q.ninvoke im(filePath), 'size'
  isSizeSmallerThan: (filePath, dimensions) ->
    unless dimensions? then return Q.fcall -> false
    @getSize filePath
    .then (size) =>
      expectedDimensions = @_getDimensions dimensions
      size.width < expectedDimensions.width or size.height < expectedDimensions.height
