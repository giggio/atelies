define [
  'backbone'
  'underscore'
  './logger'
], (Backbone, _, Logger) ->
  class Router extends Backbone.Router
    constructor: ->
      @logger = new Logger()
      @routes['redirect/:to'] = @_routes.redirect
      super()
    getHash: ->
      hash = Backbone.history.getFragment()
      if hash is "" then 'home' else hash
    initialize: ->
      Backbone.history.start()
      @_log()
      @_redirectIfRequested()
      Backbone.history.on 'route', => @_log()
    _log: ->
      console.log "navigated to: " + Backbone.history.getFragment() if console?
      @logger.log category: 'navigation', action: "#{window.location.pathname}##{@getHash()}", label: @logCategory, field: page: window?.location?.pathname
    _redirectIfRequested: ->
      if boostrapedRedirect?
        Backbone.history.navigate boostrapedRedirect, trigger: true
