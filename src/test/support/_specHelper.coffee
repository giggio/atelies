process.env.NODE_ENV = 'test'
require '../../globals'
require './_addLibsHelper'
require './matchersHelper'

exportAll = (obj) ->
  global[key] = value for key,value of obj

exportAll require './waitHelper'

global.exportAll = exportAll
exports.exportAll = exportAll
global.print = console.log
