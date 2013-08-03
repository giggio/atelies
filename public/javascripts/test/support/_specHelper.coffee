requirejs ['./generatorHelper'], (g) ->
  exportAll g
  requirejs './backboneConfig'
  global.staticPath = '/static'
