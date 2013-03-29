requirejs = require("requirejs")


# set up require.js to play nicely with the test environment
requirejs.config
  baseUrl: "./public/javascripts"
  nodeRequire: require
  paths:
    
    # paths to coffeescript+cs wrapper plugin
    cs: "src/plugins/cs"
    CoffeeScript: "src/libs/CoffeeScript"
    text: 'lib/text'


# make define available globally like it is in the browser
global.define = require("requirejs")
jasmine = require("jasmine-node")

# map jasmine methods to global namespace
for key of jasmine
  global[key] = jasmine[key]  if jasmine[key] instanceof Function

# Test helper: set up a faux-DOM for running browser tests
global.initDOM = ->
  
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
  global.initDOM()
  
  # add Backbone to global namespace and tell it to use jQuery
  global.Backbone = require("backbone")
  if global.Backbone.setDomLibrary is undefined
    global.Backbone.$ = jQuery
  else
    global.Backbone.setDomLibrary jQuery


specs = ["../spec/HomeView.spec"]
requirejs specs, ->
  reporter = new jasmine.ConsoleReporter()
  oldReportRunnerResults = reporter.reportRunnerResults
  assertionCount =
    total: 0
    passed: 0
    failed: 0

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
    #console.log "Total: " + assertionCount.total
    #console.log "Passed: " + assertionCount.passed
    #console.log "Failed: " + assertionCount.failed
    process.exit assertionCount.failed

  
  # tell Jasmine to use the boring console reporter:
  jasmine.getEnv().addReporter reporter
  #jasmine.specFilter = (spec) ->
  #  reporter.specFilter spec

  
  # execute all specs
  jasmine.getEnv().execute()
