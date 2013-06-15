_s              = require 'underscore.string'

String::endsWith = (expected) ->
  _s.endsWith @, expected

exports.similar = (a, b) ->
  for k, v of a
    if typeof v isnt 'function'
      if v isnt b[k]
        return false
  for k, v of b
    if typeof v isnt 'function'
      if v isnt a[k]
        return false

  return true
