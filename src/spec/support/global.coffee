exports.beforeAll = (func) =>
  @func = func

beforeEach =>
  return if @beforeAllCalled
  @beforeAllCalled = true
  @func() if @func
