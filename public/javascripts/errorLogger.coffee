define [
  'jquery'
], ($) ->
  class ErrorLogger
    @logError: (area, message, path, verb, otherInfo={}) ->
      try
        if message instanceof Error
          message = err.message
          try
            throw new Error()
          catch e
            stack = e.stack + "\nOriginal Error Stack:\n" + message.stack
        else
          message = if typeof message is 'string' then message else JSON.stringify message
          try
            throw new Error()
          catch e
            stack = e.stack
        message = "No error message provided." if message is ""
        otherInfo.location = window.location.toString()
        $.post '/api/error',
          module: area
          message: message
          stack: stack
          path: path
          verb: verb
          otherInfo: JSON.stringify(otherInfo)
      catch e
        if console?
          console.log "Not able to log error. Problem:\n#{JSON.stringify e}"
