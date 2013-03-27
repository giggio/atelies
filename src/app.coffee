exports.start = (cb) ->
  express = require("express")
  routes = require("./routes")
  http = require("http")
  path = require("path")
  app = express()

  app.configure "development", ->
    app.use express.logger "dev"
    app.use express.errorHandler()
    app.locals.pretty = on

  app.configure ->
    app.set "port", process.env.PORT or 3000
    app.set "views", __dirname + "/views"
    app.set "view engine", "jade"
    app.use express.favicon()
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use app.router
    app.use express.static(path.join(__dirname, "public"))

  app.get "/", routes.index
  exports.server = http.createServer(app).listen app.get("port"), ->
    console.log "Express server listening on port #{app.get("port")} on environment #{app.get('env')}"
    cb(exports.server) if cb

exports.stop = ->
  exports.server.close()
