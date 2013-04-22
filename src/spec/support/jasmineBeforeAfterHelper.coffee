jasmine.Suite::beforeAll = (func) ->
  @beforeAllFuncs = [] unless @beforeAllFuncs?
  @beforeAllFuncs.push func

exports.beforeAll = (func) ->
  currentSuite = jasmine.getEnv().currentSuite
  currentSuite.beforeAll func

exports.beforeAllSpecs = (func) ->
  runner = jasmine.getEnv().currentRunner()
  runner.beforeAllFuncs = [] unless runner.beforeAllFuncs?
  runner.beforeAllFuncs.push func

exports.afterAll = (func) =>
  @afterAllFuncs = [] unless @afterAllFuncs?
  @afterAllFuncs.push func

exports._setupAfterAll = ->
  return if @setupAfterAll
  @setupAfterAll = true
  runner = jasmine.getEnv().currentRunner()
  oldFinishCallback = runner.finishCallback
  self = @
  runner.finishCallback = ->
    oldFinishCallback.apply @, arguments
    return unless self.afterAllFuncs?
    for afterAllFunc in self.afterAllFuncs
      afterAllFunc()

@getSuites = ->
  suites = []
  suite = @suite
  while suite?
    suites.push suite
    suite = suite.parentSuite
  suites.push jasmine.getEnv().currentRunner()
  suites

that = @

beforeEach (done) ->
  exports._setupAfterAll()
  #'this' here means the test, the 'it'
  suites = that.getSuites.apply @
  suites = suites.reverse()

  callSuite = (suite, remainingSuites...) ->
    continueSuiteCalls = ->
      if remainingSuites.length is 0
        process.nextTick done
      else
        callSuite remainingSuites...
    if suite.beforeAllFuncs? and not suite.beforeAllCalled
      suite.beforeAllCalled = true
      i = suite.beforeAllFuncs.length
      for beforeFunc in suite.beforeAllFuncs
        if beforeFunc.length is 0
          beforeFunc()
          i--
        else
          beforeFunc -> i--
      continueWhenIIs0 = ->
        return continueSuiteCalls() if i is 0
        process.nextTick continueWhenIIs0
      continueWhenIIs0()
    else
      continueSuiteCalls()

  callSuite suites...
