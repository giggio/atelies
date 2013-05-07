module.exports = class AccessDenied extends Error
  constructor: ->
    @name = 'AccessDenied'
