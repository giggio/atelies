Q           = require 'q'

exports.whenDone = (condition) ->
  d = Q.defer()
  if condition()
    d.resolve()
  else
    setImmediate -> whenDone(condition).then d.resolve
  d.promise
    

exports.waitSeconds = (seconds) -> exports.waitMilliseconds seconds * 1000

exports.waitMilliseconds = (mils) ->
  future = new Date()
  future.setMilliseconds(new Date().getMilliseconds()+mils)
  exports.whenDone ->
    now = new Date()
    now > future
