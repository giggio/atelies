_s              = require 'underscore.string'

String::endsWith = (expected) ->
  _s.endsWith @, expected
