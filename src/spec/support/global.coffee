exports.beforeAll = (func) =>
  @beforeAllFunc = func

exports.afterAll = (func) =>
  @afterAllFunc = func

exports._setupAfterAll = ->
  runner = jasmine.getEnv().currentRunner()
  oldFinishCallback = runner.finishCallback
  self = @
  runner.finishCallback = ->
    oldFinishCallback.apply @, arguments
    self.afterAllFunc() if self.afterAllFunc

beforeEach =>
  return if @beforeAllCalled
  @beforeAllCalled = true
  exports._setupAfterAll()
  @beforeAllFunc() if @beforeAllFunc
