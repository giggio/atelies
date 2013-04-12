@beforeAllFunc = []

exports.beforeAll = (func) =>
  @beforeAllFunc.push func

exports.afterAll = (func) =>
  @afterAllFunc = func

exports._setupAfterAll = ->
  runner = jasmine.getEnv().currentRunner()
  oldFinishCallback = runner.finishCallback
  self = @
  runner.finishCallback = ->
    oldFinishCallback.apply @, arguments
    self.afterAllFunc() if self.afterAllFunc

beforeEach (done) =>
  return done() if @beforeAllCalled
  @beforeAllCalled = true
  exports._setupAfterAll()
  return done() if @beforeAllFunc.length is 0
  i = @beforeAllFunc.length
  for beforeFunc in @beforeAllFunc
    beforeFunc -> i--
  callDoneWhenIIs0 = ->
    return done() if i is 0
    process.nextTick callDoneWhenIIs0
  callDoneWhenIIs0()
