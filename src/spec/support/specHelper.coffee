require './jasmineMatchersHelper'

exports.whenDone = (condition, callback) ->
  if condition()
    process.nextTick callback
  else
    process.nextTick -> whenDone(condition, callback)
