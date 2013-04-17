path    = require 'path'
fs      = require 'fs'

process.addListener 'uncaughtException', (error) -> console.log "Error happened:\n#{error.stack}"

javascriptsPath = path.join __dirname, 'public', 'javascripts'
specsPath = path.join javascriptsPath, 'spec'

isASpecFile = (file) -> file.indexOf(".spec.coffee", file.length - 12) isnt -1
isAHelperFile = (file) -> file.indexOf("Helper.coffee", file.length - 13) isnt -1

addFilesFromDir = (dirPath, isCorrectFile) ->
  files = []
  for dirItem in fs.readdirSync dirPath
    fullItemPath = path.join dirPath, dirItem
    continue unless fs.existsSync fullItemPath
    isDirectory =  fs.statSync(fullItemPath).isDirectory()
    if isDirectory
      files = files.concat addFilesFromDir fullItemPath, isCorrectFile
    else
      continue unless isCorrectFile fullItemPath
      relativePath = fullItemPath.substring javascriptsPath.length + 1, fullItemPath.length - 1
      fileWithoutExt = relativePath.substring 0, relativePath.length - path.extname(relativePath).length
      files.push fileWithoutExt
  files

specs = addFilesFromDir specsPath, isASpecFile
helpers = addFilesFromDir specsPath, isAHelperFile

# set up require.js to play nicely with the test environment
requirejs = require("requirejs")
requirejs.config
  baseUrl: "./public/javascripts"
  nodeRequire: require
  paths:
    text: 'lib/text'

# map jasmine methods to global namespace
jasmine = require("jasmine-node")
for key of jasmine
  global[key] = jasmine[key]  if jasmine[key] instanceof Function
  
# Test helper: set up a faux-DOM for running browser tests
initDOM = ->
  # Create a DOM
  jsdom = require("jsdom")
  # create a jQuery instance
  jQuery = require("jquery")
  global.jQuery = global.$ = jQuery
  # Create window
  window = jsdom.jsdom().createWindow("<html><body></body></html>")
  global.window = window
  # Set up global references for DOMDocument+jQuery
  global.document = window.document
  # add addEventListener for coffeescript compatibility:
  global.addEventListener = window.addEventListener
  unless window.localStorage?
    LocalStorage = require('node-localstorage').LocalStorage
    window.localStorage = new LocalStorage(path.join __dirname, '.localstorage-test')
    global.localStorage = window.localStorage

# Test helper: set up Backbone.js with a browser-like environment
global.initBackbone = ->
  # Get a headless DOM ready for action
  initDOM()
  # tell backbone to use jQuery
  require("backbone").$ = jQuery

initBackbone()
requirejs helpers, ->
  for helper in arguments
    for key of helper
      global[key] = helper[key]

  # set to some specific test:
  # specs = [ 'spec/store/productView.spec']
  requirejs specs, ->
    reporter = new jasmine.TerminalReporter(color: true)
    oldReportRunnerResults = reporter.reportRunnerResults
    assertionCount = total: 0, passed: 0, failed: 0

    reporter.reportRunnerResults = (runner) ->
      oldReportRunnerResults.apply reporter, [runner]
      specs = runner.specs()
      specResults = undefined
      i = 0
      while i < specs.length
        specResults = specs[i].results()
        assertionCount.total += specResults.totalCount
        assertionCount.passed += specResults.passedCount
        assertionCount.failed += specResults.failedCount
        ++i
      process.exit assertionCount.failed

    jasmineEnv = jasmine.getEnv()
    jasmineEnv.addReporter reporter
    jasmineEnv.execute()
