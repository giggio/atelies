define [
  './errorLogger'
], (ErrorLogger) ->
  class Routes
    redirect: (to) ->
      Backbone.history.navigate to, trigger: true
    logXhrError: (xhr, otherInfo) ->
      @logError xhr.responseText, otherInfo if xhr.status is 400
    logError: (message, otherInfo) ->
      ErrorLogger.logError @area, message, '', '', otherInfo
