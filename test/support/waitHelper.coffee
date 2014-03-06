Q           = require 'q'
exports.whenDone = (condition, cb) ->
  if cb?
    if condition()
      setImmediate cb
    else
      setImmediate -> whenDone(condition, cb)
    return
  d = Q.defer()
  if condition()
    d.resolve()
  else
    setImmediate -> whenDone(condition).then d.resolve
  return d.promise
    

exports.waitSeconds = (seconds, cb) -> return exports.waitMilliseconds seconds * 1000, cb

exports.waitMilliseconds = (mils, cb) ->
  future = new Date()
  future.setMilliseconds(new Date().getMilliseconds()+mils)
  if cb?
    exports.whenDone ->
      now = new Date()
      now > future
    , cb
    return
  return exports.whenDone ->
    now = new Date()
    now > future
