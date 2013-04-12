path    = require 'path'
fs      = require 'fs'

process.addListener 'uncaughtException', (error) -> console.log "Error happened:\n#{error.stack}"

specs = []
basePath = path.join __dirname, 'public', 'javascripts', 'spec'
for dirItem in fs.readdirSync basePath
  fullItemPath = path.join basePath, dirItem
  continue if fs.statSync(fullItemPath).isDirectory()
  fileWithoutExt = dirItem.substring 0, dirItem.length - path.extname(dirItem).length
  specs.push path.join "spec", fileWithoutExt

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
  jQuery = require("jquery").create()
  global.jQuery = global.$ = jQuery
  # Create window
  window = jsdom.jsdom().createWindow("<html><body></body></html>")
  # Set up global references for DOMDocument+jQuery
  global.document = window.document
  # add addEventListener for coffeescript compatibility:
  global.addEventListener = window.addEventListener


# Test helper: set up Backbone.js with a browser-like environment
global.initBackbone = ->
  # Get a headless DOM ready for action
  initDOM()
  # tell backbone to use jQuery
  require("backbone").$ = jQuery

initBackbone()

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
