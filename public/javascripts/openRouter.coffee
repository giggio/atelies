define [
  'backbone'
  './logger'
], (Backbone, Logger) ->
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
      @logger.log event:'navigation', category:'admin', action: @getHash()
      @_redirectIfRequested()
      Backbone.history.on 'route', (router, route, params) =>
        console.log "navigated to: " + Backbone.history.getFragment()
        @logger.log event:'navigation', category:'admin', action: @getHash()
    _redirectIfRequested: ->
      if boostrapedRedirect?
        Backbone.history.navigate boostrapedRedirect, trigger: true
