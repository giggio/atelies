jade        = require 'jade'
fs          = require 'fs'
path        = require 'path'
jsdom       = require("jsdom").jsdom

exports.viewPath = (name) -> path.join(__dirname, "..", '..', '..', '..', 'app', 'views', "#{name}.jade")

exports.viewContent = (viewName, cb) ->
  viewPath = exports.viewPath viewName
  fs.readFile viewPath, 'utf8', (err, jadeContent) ->
    cb err, jadeContent

exports.compileJade = (viewName, cb) ->
  viewPath = exports.viewPath viewName
  jadeContent = exports.viewContent viewName, (err, jadeContent) ->
    return cb err if err
    try
      jadeResult = jade.compile jadeContent, pretty: true, filename: viewPath
    catch err
      return cb err
    cb null, jadeResult

exports.getHtmlFromView = (viewName, data, cb) ->
  exports.compileJade viewName, (err, jadeResult) ->
    return cb err if err
    unless data.everyauth?
      data.everyauth =
        loggedIn: false
        password:
          loginFormFieldName: 'login'
          passwordFormFieldName: 'password'
    try
      html = jadeResult data
    catch err
      cb err
    cb null, html

exports.getWindowFor = (html, cb) ->
  fs.readFile path.join(__dirname, "../../../../public/javascripts/lib/jquery.min.js".split('/')...), (err, jqueryFile) ->
    return cb err, null if err
    jsdom.env html: html, src: [jqueryFile], done: (err, window) ->
      cb null, window, window?.$

exports.getWindowFromView = (viewName, data, cb) ->
  exports.getHtmlFromView viewName, data, (err, html) ->
    return cb err if err
    exports.getWindowFor html, (err, window, $) ->
      cb null, window, window?.$
