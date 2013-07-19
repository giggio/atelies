mongoose            = require 'mongoose'
exports.start = (cb) ->
  require './globals'
  require './helpers/expressExtensions'
  require './helpers/languageExtensions'
  everyauth           = require 'everyauth'
  express             = require "express"
  http                = require "http"
  path                = require "path"
  app                 = express()
  everyauthConfig     = require './helpers/everyauthConfig'
  router              = require './routes/router'
  less                = require 'connect-less'
  Postman             = require './models/postman'
  MongoStore          = require('connect-mongo')(express)
  config              = require './helpers/config'

  switch app.get("env")
    when 'development'
      isProduction = false
      cookieSecret = "abc"
      app.use express.logger "dev"
      app.use express.errorHandler()
      app.locals.pretty = on
      everyauth.debug = on
      if config.test.sendMail
        console.log "SENDING MAIL!"
        Postman.configure config.aws.accessKeyId, config.aws.secretKey
      else
        Postman.dryrun = on
      sessionStore = new express.session.MemoryStore()
      connStr = "mongodb://localhost/openstore"
      domain = 'localhost.com'
      port = 3000
      publicDir = path.join __dirname, '..', "public"
    when "test"
      isProduction = false
      cookieSecret = "abc"
      #app.use express.logger "dev"
      app.use express.errorHandler()
      app.locals.pretty = on
      #everyauth.debug = on
      Postman.dryrun = on
      sessionStore = new express.session.MemoryStore()
      connStr = "mongodb://localhost/openstoretest"
      domain = 'localhost.com'
      port = 8000
      publicDir = path.join __dirname, '..', "public"
    when "production"
      isProduction = true
      cookieSecret = config.appCookieSecret
      Postman.configure config.aws.accessKeyId, config.aws.secretKey
      connStr = config.connectionString
      sessionStore = new MongoStore url:connStr
      domain = config.baseDomain
      port = 3000
      publicDir = path.join __dirname, '..', "compiledPublic"

  global.DEBUG = !isProduction

  app.set "port", config.port or port
  app.set "views", path.join __dirname, "views"
  app.set "view engine", "jade"
  app.set 'domain', domain

  app.use express.favicon path.join publicDir, 'images', 'favicon.ico'
  app.use express.compress() if isProduction
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser cookieSecret
  app.use express.session secret: cookieSecret, store:sessionStore
  app.use less src: publicDir, debug: false, compress: isProduction
  app.use express.static publicDir
  everyauthConfig.configure app
  app.use everyauth.middleware()
  mongoose.connect connStr
  mongoose.connection.on 'error', dealWith

  router.route app
  
  process.on 'exit', -> Postman.stop()

  server = http.createServer(app)
  if app.get("env") isnt 'production'
    server.sessionStore = sessionStore
    server.cookieSecret = cookieSecret
  exports.server = server
  server.listen app.get("port"), ->
    console.log "Express server listening on port #{app.get("port")} on environment #{app.get('env')}"
    console.log "Mongo database connection string: #{connStr}" if app.get("env") isnt 'production'
    cb(exports.server) if cb

exports.stop = ->
  exports.server.close()
  mongoose.connection.close()
  mongoose.disconnect()
