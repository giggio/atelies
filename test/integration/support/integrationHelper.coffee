mongoose    = require 'mongoose'
app         = require '../../../app/app'
Q           = require 'q'
config      = require '../../../app/helpers/config'
verbose = config.test.verbose

exports.localMongoDB = "mongodb://localhost/ateliesteste"

exports.startServer = ->
  write "startServer: starting server...".cyan
  app.start()
  .then (server) ->
    exports.expressServer = server
    write "startServer: server started".cyan

exports.whenServerLoaded = -> whenDone (-> exports.expressServer isnt null)

exports.openNewConnection = ->
  d = Q.defer()
  conn = mongoose.createConnection exports.localMongoDB
  conn.on 'error', (err) ->
    console.error "connection error:#{err.stack}"
    d.reject err
  conn.once 'open', -> d.resolve conn
  d.promise

write = (msg) -> if verbose then console.log new Date().toLocaleTimeString(), msg
exports.write = write

exports.cleanDB = ->
  write "cleanDB: cleaning...".cyan
  exports.openNewConnection()
  .then (conn) ->
    write "cleanDB: got connection".cyan
    Q.ninvoke conn.db, "collections"
    .then (cols) ->
      write "cleanDB: got collections".cyan
      dropAll = for col in cols
        do (col) ->
          Q.fcall ->
            unless col.collectionName.substring(0,6) is 'system'
              #console.info "dropping #{col.collectionName}" if process.env.DEBUG
              Q.ninvoke col, 'drop'
              .catch (err) -> throw err if err.message isnt 'ns not found'
      Q.allSettled dropAll
    .then -> Q.ninvoke conn, 'close'
    .then -> write "cleanDB: done".cyan

before ->
  exports.cleanDB()
  .then -> exports.startServer()

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
