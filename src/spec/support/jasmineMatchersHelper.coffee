_s              = require 'underscore.string'

matchersPrototype =
  toEndWith: (expected) ->
    _s.endsWith @actual, expected
  
jEnv = jasmine.getEnv()
parent = jEnv.matchersClass
newMatchersClass = ->
  parent.apply this, arguments
jasmine.util.inherit newMatchersClass, parent
jasmine.Matchers.wrapInto_ matchersPrototype, newMatchersClass
jEnv.matchersClass = newMatchersClass
