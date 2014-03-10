mongoose    = require 'mongoose'
app         = require '../../../app/app'
Q           = require 'q'

exports.localMongoDB = "mongodb://localhost/ateliesteste"

exports.startServer = (cb) ->
  app.start()
  .then (server) ->
    exports.expressServer = server
    cb null, server if cb?
  .catch (err) ->
    if cb?
      cb err, null if cb?
    else
      throw err

exports.whenServerLoaded = -> whenDone (-> exports.expressServer isnt null)

exports.openNewConnection = ->
  d = Q.defer()
  conn = mongoose.createConnection exports.localMongoDB
  conn.on 'error', (err) ->
    console.error "connection error:#{err.stack}"
    d.reject err
  conn.once 'open', -> d.resolve conn
  d.promise

exports.cleanDB = (cb) ->
  exports.openNewConnection()
  .then (conn) ->
    Q.ninvoke conn.db, "collections"
    .then (cols) ->
      for col in cols
        unless col.collectionName.substring(0,6) is 'system'
          #console.info "dropping #{col.collectionName}" if process.env.DEBUG
          col.drop()
      conn.close()
      cb() if cb?

before (done) ->
  exports.cleanDB (err) ->
    return done err if err?
    process.env.DEBUG = on
    exports.startServer (err, server) ->
      done err if err?
      done()

after ->
  if exports.expressServer
    app.stop()
  else
    console.info "Server not defined on 'afterAll'"

exports.doneError = (error, done) ->
  if error
    console.error "Error happened: " + error.stack
    done error
  else
    done()

exports.getExpressServer = -> exports.expressServer
