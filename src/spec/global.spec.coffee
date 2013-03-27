beforeAll = (func) =>
  @func = func

beforeAll ->
  process.addListener 'uncaughtException', (error) -> console.log "Error: #{error}"

beforeEach =>
  return if @beforeAllCalled
  @beforeAllCalled = true
  @func() if @func
