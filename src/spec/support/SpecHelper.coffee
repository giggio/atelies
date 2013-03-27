jade    = require 'jade'
fs      = require 'fs'
path    = require 'path'
jsdom   = require("jsdom").jsdom
global  = require './global'

exports.viewPath = (name) -> path.join(__dirname, '..', '..', 'views', "#{name}.jade")

exports.viewContent = (viewName, cb) ->
  viewPath = exports.viewPath viewName
  fs.readFile viewPath, 'utf8', (err, jadeContent) ->
    cb(err, jadeContent)

exports.compileJade = (viewName, cb) ->
  viewPath = exports.viewPath viewName
  jadeContent = exports.viewContent viewName, (err, jadeContent) ->
    cb(err) if err
    try
      jadeResult = jade.compile(jadeContent, {pretty: true, filename: viewPath})
    catch err
      cb(err)
    cb(null, jadeResult)

exports.getHtmlFromView = (viewName, data, cb) ->
  exports.compileJade viewName, (err, jadeResult) ->
    cb(err) if err
    try
      html = jadeResult(data)
    catch err
      cb(err)
    cb(null, html)

exports.getWindowFor = (html, cb) ->
  fs.readFile path.join(__dirname, "../../public/javascripts/lib/jquery.min.js".split('/')...), (err, jqueryFile) ->
    cb(err, null) if err
    jsdom.env html: html, src: [jqueryFile], done: (err, window) ->
      cb(err) if err
      cb(null, window, window.$)

exports.getWindowFromView = (viewName, data, cb) ->
  exports.getHtmlFromView viewName, data, (err, html) ->
    cb(err) if err
    exports.getWindowFor html, (err, window, $) ->
      cb(err) if err
      cb(null, window, window.$)

exports.patchEventEmitterToHideMaxListenerWarning = ->
  return if exports.eventEmitterPatched
  exports.eventEmitterPatched = true
  events = require('events')
  Old = events.EventEmitter
  events.EventEmitter = ->
    this.setMaxListeners(0)
  events.EventEmitter:: = Old::

global.beforeAll ->
  process.addListener 'uncaughtException', (error) -> console.log "Error: #{error}"
  exports.patchEventEmitterToHideMaxListenerWarning()

exports.startServer = (cb) ->
  app = require('../../app')
  app.start(cb)
