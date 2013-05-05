exports.whenDone = (condition, callback) ->
  if condition()
    setImmediate callback
  else
    setImmediate -> whenDone(condition, callback)

exports.waitSeconds = (seconds, callback) ->
  future = new Date()
  future.setSeconds(new Date().getSeconds()+seconds)
  exports.whenDone ->
    now = new Date()
    now > future
  , callback
