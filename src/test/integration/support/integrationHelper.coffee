#helper      = require './specHelper'
mongoose    = require 'mongoose'
app         = require '../../../app'

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
  app.start (server) ->
    exports._server = server
    cb null, server if cb

exports.whenServerLoaded = (cb) ->
  if exports._server
    setImmediate cb
    return
  exports.whenDone((-> exports._server isnt null), -> cb())

exports.openNewConnection = (cb) ->
  process.env.CUSTOMCONNSTR_mongo = exports.localMongoDB unless process.env.CUSTOMCONNSTR_mongo
  conn = mongoose.createConnection process.env.CUSTOMCONNSTR_mongo
  conn.on 'error', (err) ->
    console.error "connection error:#{err.stack}"
    cb err, null
  conn.once 'open', -> cb null, conn


exports.cleanDB = (cb) ->
  exports.openNewConnection (err, conn) ->
    return cb err if err
    conn.db.collections (err, cols) ->
      for col in cols
        unless col.collectionName.substring(0,6) is 'system'
          console.info "dropping #{col.collectionName}" if process.env.DEBUG_JASMINE
          col.drop()
      conn.close()
      cb()

before (done) ->
  #process.addListener 'uncaughtException', (error) -> console.error "Error happened:\n#{error.stack}" #needed before with jasmine, not with mocha, lets wait and see
  exports.patchEventEmitterToHideMaxListenerWarning()
  exports.cleanDB (err) ->
    if err
      done err
      return
    exports.startServer (err, server) ->
      done err if err
      done()

after ->
  if exports._server
    app.stop()
  else
    console.info "Server not defined on 'afterAll'"

exports.doneError = (error, done) ->
  if error
    console.error "Error happened: " + error.stack
    done error
  else
    done()
