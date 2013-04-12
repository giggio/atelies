jasmineExt  = require './JasmineExtensions'
helper      = require '../../support/SpecHelper'

for key,value of helper
  exports[key] = value

exports.patchEventEmitterToHideMaxListenerWarning = ->
  return if exports.eventEmitterPatched
  exports.eventEmitterPatched = true
  events = require('events')
  Old = events.EventEmitter
  events.EventEmitter = ->
    this.setMaxListeners(0)
  events.EventEmitter:: = Old::

exports.localMongoDB = "mongodb://localhost/openstore"

exports.startServer = (cb) ->
  app = require '../../../app'
  app.start (server) ->
    exports._server = server
    cb null, server if cb

exports.whenServerLoaded = (cb) ->
  if exports._server
    process.nextTick cb
    return
  exports.whenDone((-> exports._server isnt null), -> cb())

exports.cleanDB = (cb) ->
  process.env.CUSTOMCONNSTR_mongo = exports.localMongoDB
  mongoose = require 'mongoose'
  mongoose.connect process.env.CUSTOMCONNSTR_mongo
  mongoose.connection.on 'error', (err) ->
    console.error "connection error:#{err.stack}"
    cb err
  mongoose.connection.db.collections (err, cols) ->
    for col in cols
      unless col.collectionName.substring(0,6) is 'system'
        console.info "dropping #{col.collectionName}" if process.env.DEBUG_JASMINE
        col.drop()
    mongoose.connection.close()
    cb()

jasmineExt.beforeAll (done) ->
  process.addListener 'uncaughtException', (error) -> console.error "Error happened:\n#{error.stack}"
  exports.patchEventEmitterToHideMaxListenerWarning()
  exports.cleanDB (err) ->
    if err
      done err
      return
    exports.startServer (err, server) ->
      done err if err
      done()

jasmineExt.afterAll ->
  if exports._server
    exports._server.close()
  else
    console.info "Server not defined on 'afterAll'"
