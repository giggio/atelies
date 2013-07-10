process.env.NODE_ENV = 'test'
global.DEBUG = true
require '../../app/helpers/languageExtensions'
require '../../app/globals'
require './_addLibsHelper'
matchers = require './matchersHelper'

exportAll = (obj) ->
  global[key] = value for key,value of obj

exportAll require './waitHelper'
exportAll matchers

global.exportAll = exportAll
exports.exportAll = exportAll
global.print = console.log
exportAll require './generatorHelper'
