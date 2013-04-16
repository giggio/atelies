mongoose      = require 'mongoose'
exports.start = (cb) ->
  express       = require "express"
  routes        = require "./routes"
  http          = require "http"
  path          = require "path"
  app           = express()

  app.configure "development", ->
    process.env.CUSTOMCONNSTR_mongo = 'mongodb://localhost/openstore' unless process.env.CUSTOMCONNSTR_mongo
    app.use express.logger "dev"
    app.use express.errorHandler()
    app.locals.pretty = on

  port = process.env.PORT or
    switch app.get 'env'
      when 'development', 'production' then 3000
      when 'test' then 8000
      else 3000

  app.configure ->
    app.set "port", port
    app.set "views", __dirname + "/views"
    app.set "view engine", "jade"
    app.use express.favicon()
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use express.static(path.join(__dirname, "public"))
    app.use app.router
    console.log "Mongo database connection string: " + process.env.CUSTOMCONNSTR_mongo if app.get("env") is 'development'
    mongoose.connect process.env.CUSTOMCONNSTR_mongo
    mongoose.connection.on 'error', (err) ->
      console.error "connection error:#{err.stack}"
      throw err

  app.get "/", routes.index
  app.get "/:storeSlug", routes.store
  app.get "/:storeSlug/:productSlug", routes.product
  exports.server = http.createServer(app).listen app.get("port"), ->
    console.log "Express server listening on port #{app.get("port")} on environment #{app.get('env')}"
    cb(exports.server) if cb

exports.stop = ->
  exports.server.close()
  mongoose.connection.close()
  mongoose.disconnect()
