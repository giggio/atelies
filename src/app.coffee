require './globals'
require './expressExtensions'
mongoose        = require 'mongoose'
everyauth           = require 'everyauth'
exports.start = (cb) ->
  express             = require "express"
  routes              = require "./routes"
  http                = require "http"
  path                = require "path"
  app                 = express()
  everyauthConfig     = require './helpers/everyauthConfig'
  router              = require './routes/router'

  cookieSecret = if app.get("env") isnt 'production' then "abc" else process.env.APP_COOKIE_SECRET
  app.configure "development", ->
    process.env.CUSTOMCONNSTR_mongo = 'mongodb://localhost/openstore' unless process.env.CUSTOMCONNSTR_mongo
    app.use express.logger "dev"
    app.use express.errorHandler()
    app.locals.pretty = on
    everyauth.debug = on
  
  app.configure "test", ->
    process.env.CUSTOMCONNSTR_mongo = 'mongodb://localhost/openstore' unless process.env.CUSTOMCONNSTR_mongo
    #app.use express.logger "dev"
    app.use express.errorHandler()
    app.locals.pretty = on
    #everyauth.debug = on

  port = process.env.PORT or
    switch app.get 'env'
      when 'development', 'production' then 3000
      when 'test' then 8000
      else 3000

  app.use express.favicon()
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser cookieSecret
  app.use express.session()
  app.use express.static(path.join(__dirname, "public"))
  everyauthConfig.configure()
  app.use(everyauthConfig.preEveryAuthMiddlewareHack())
  app.use everyauth.middleware app
  app.use(everyauthConfig.postEveryAuthMiddlewareHack())
  #app.use app.router
  console.log "Mongo database connection string: " + process.env.CUSTOMCONNSTR_mongo if app.get("env") is 'development'
  mongoose.connect process.env.CUSTOMCONNSTR_mongo
  mongoose.connection.on 'error', (err) ->
    console.error "connection error:#{err.stack}"
    throw err
  #app.dynamicHelpers currentUser: (req, res) -> req.user

  app.configure ->
    app.set "port", port
    app.set "views", __dirname + "/views"
    app.set "view engine", "jade"

  router.route app

  exports.server = http.createServer(app).listen app.get("port"), ->
    console.log "Express server listening on port #{app.get("port")} on environment #{app.get('env')}"
    cb(exports.server) if cb

exports.stop = ->
  exports.server.close()
  mongoose.connection.close()
  mongoose.disconnect()

