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

  cookieSecret = if app.get("env") isnt 'production' then "abc" else process.env.APP_COOKIE_SECRET
  app.configure "development", ->
    process.env.CUSTOMCONNSTR_mongo = 'mongodb://localhost/openstore' unless process.env.CUSTOMCONNSTR_mongo
    app.use express.logger "dev"
    app.use express.errorHandler()
    app.locals.pretty = on
    everyauth.debug = on
    if process.env.SEND_MAIL?
      console.log "SENDING MAIL!"
      Postman.configure process.env.SMTP_USER, process.env.SMTP_PASSWORD
    else
      Postman.dryrun = on
  
  app.configure "test", ->
    process.env.CUSTOMCONNSTR_mongo = 'mongodb://localhost/openstore' unless process.env.CUSTOMCONNSTR_mongo
    #app.use express.logger "dev"
    app.use express.errorHandler()
    app.locals.pretty = on
    #everyauth.debug = on
    Postman.dryrun = on

  app.configure "production", ->
    Postman.configure process.env.SMTP_USER, process.env.SMTP_PASSWORD

  port = process.env.PORT or switch app.get 'env'
    when 'development', 'production' then 3000
    when 'test' then 8000
    else 3000

  app.set "port", port
  app.set "views", path.join __dirname, "views"
  app.set "view engine", "jade"

  sessionStore = new express.session.MemoryStore()

  app.use express.favicon()
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser cookieSecret
  app.use express.session store:sessionStore
  app.use less src: path.join(__dirname, '..', 'public'), debug:false
  app.use express.static(path.join(__dirname, '..', "public"))
  everyauthConfig.configure app
  app.use everyauth.middleware()
  #app.use app.router
  connStr = if process.env.MONGOLAB_URI? then process.env.MONGOLAB_URI else process.env.CUSTOMCONNSTR_mongo
  mongoose.connect connStr
  mongoose.connection.on 'error', dealWith

  if app.get("env") is 'production'
    app.set 'domain', 'atelies.com.br'
  else
    app.set 'domain', 'localhost.com'

  router.route app
  
  process.on 'exit', ->
    Postman.stop()

  server = http.createServer(app)
  if app.get("env") isnt 'production'
    server.sessionStore = sessionStore
    server.cookieSecret = cookieSecret
  exports.server = server
  server.listen app.get("port"), ->
    console.log "Express server listening on port #{app.get("port")} on environment #{app.get('env')}"
    console.log "Mongo database connection string: " + process.env.CUSTOMCONNSTR_mongo if app.get("env") is 'development'
    cb(exports.server) if cb

exports.stop = ->
  exports.server.close()
  mongoose.connection.close()
  mongoose.disconnect()
