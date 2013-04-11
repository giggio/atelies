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

beforeEach (done) =>
  if @beforeAllCalled
    done()
    return
  @beforeAllCalled = true
  exports._setupAfterAll()
  if @beforeAllFunc
    @beforeAllFunc done
  else
    done()
