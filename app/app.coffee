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
  redirectUnlessSecure= require './helpers/middleware/redirectUnlessSecure'

  if app.get("env") is 'production'
    config.isProduction = true
    Postman.configure config.aws.accessKeyId, config.aws.secretKey
    sessionStore = new MongoStore url:config.connectionString
    publicDir = path.join __dirname, '..', "compiledPublic"
  else
    config.isProduction = false
    app.use express.errorHandler()
    app.locals.pretty = on
    sessionStore = new express.session.MemoryStore()
    publicDir = path.join __dirname, '..', "public"
    if app.get("env") is 'development'
      config.connectionString = "mongodb://localhost/atelies"
      app.use express.logger "dev"
      everyauth.debug = on
      config.port ||= 3000
      if config.test.sendMail
        console.log "SENDING MAIL!"
        Postman.configure config.aws.accessKeyId, config.aws.secretKey
      else
        Postman.dryrun = on
    if app.get("env") is 'test'
      config.connectionString = "mongodb://localhost/ateliesteste"
      #app.use express.logger "dev"
      #everyauth.debug = on
      config.port ||= 8000
      Postman.dryrun = on

  global.DEBUG = !config.isProduction
  global.CONFIG = config
  global.STATIC_PATH = config.staticPath
  app.locals.secureUrl = config.secureUrl
  app.set "port", config.port
  app.set "views", path.join __dirname, "views"
  app.set "view engine", "jade"
  app.set 'domain', config.baseDomain
  app.use express.favicon path.join publicDir, 'images', 'favicon.ico'
  #app.use express.compress() if config.isProduction #turned off as amazon already does this
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser config.appCookieSecret
  app.use express.session secret: config.appCookieSecret, store:sessionStore
  if app.get("env") isnt 'production'
    app.use less src: publicDir, debug: false, compress: config.isProduction
    app.use config.staticPath, express.static publicDir
  app.use '/account/login', redirectUnlessSecure
  app.use '/account/register', redirectUnlessSecure
  app.use '/account/changePassword', redirectUnlessSecure

  everyauthConfig.configure app
  app.use everyauth.middleware()
  mongoose.connect config.connectionString
  mongoose.connection.on 'error', dealWith

  router.route app
  
  process.on 'exit', -> Postman.stop()

  server = http.createServer(app)
  if app.get("env") isnt 'production'
    server.sessionStore = sessionStore
    server.cookieSecret = config.appCookieSecret
  exports.server = server
  server.listen app.get("port"), ->
    console.log "Express server listening on port #{app.get("port")} on environment #{app.get('env')}"
    console.log "Mongo database connection string: #{config.connectionString}" if app.get("env") isnt 'production'
    cb(exports.server) if cb

exports.stop = ->
  exports.server.close()
  mongoose.connection.close()
  mongoose.disconnect()
