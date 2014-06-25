config              = require './helpers/config'

global.dealWith = (err) ->
  if err
    console.error err.stack
    throw err
global.CONFIG = config
global.DEBUG = !config.isProduction
global.TEST = config.environment is 'test'
global.STATIC_PATH = config.staticPath
global.CLIENT_LIB_PATH = config.clientLibPath
global.callbackOrPromise = (cb, promise) ->
  if cb?
    promise
    .then -> cb null, arguments...
    .catch (err) -> cb err
  promise
