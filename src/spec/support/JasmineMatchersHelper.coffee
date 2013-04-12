JasmineExt      = require './JasmineExtensions'
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

# other things I tried:

# This works, but gets called for each spec, too much overhead
#
#beforeEach ->
#  @addMatchers #or
#  jasmine.getEnv().currentSpec.addMatchers
#    toEndWith: (expected) ->
#      _s.endsWith @actual, expected

# does not work, will add the matcher only to the first spec 
#
#JasmineExt.beforeAll (done) ->
#  jasmine.getEnv().currentSpec.addMatchers
#    toEndWith: (expected) ->
#      _s.endsWith @actual, expected
#  done()

# Doesnt work, does not wrap the call and does not fail the spec, see wrapInto_ above
#
#jasmine.Matchers::toEndWith = (expected) ->
#  _s.endsWith @actual, expected
