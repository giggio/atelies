define [
  'backbone'
  'underscore'
  './logger'
], (Backbone, _, Logger) ->
  class Router extends Backbone.Router
    constructor: ->
      @logger = new Logger()
      @routes['redirect/:to'] = @_routes.redirect
      super
    getHash: ->
      hash = Backbone.history.getFragment()
      if hash is "" then 'home' else hash
    initialize: (opt) ->
      @_serverInfo = opt.serverInfo
      @_rootUrl = @_serverInfo.rootUrl
      Backbone.history.start pushState: true, root: @_serverInfo.rootUrl
      @_logNavigation()
      @_redirectIfRequested()
      Backbone.history.on 'route', => @_navigated()
      @_redirectLinksToBackboneNavigation()
    _navigated: ->
      @_logNavigation()
      @_scroll()
    _scroll: -> window.scrollTo 0,0
    _logNavigation: ->
      console.log "navigated to: " + Backbone.history.getFragment() if console?
      @logger.log category: 'navigation', action: "#{window.location.pathname}##{@getHash()}", label: @logCategory, field: page: window?.location?.pathname
    _redirectIfRequested: ->
      if boostrapedRedirect?
        Backbone.history.navigate boostrapedRedirect, trigger: true
    _redirectLinksToBackboneNavigation: ->
      $ =>
        $("section#app-container").on "click", "a:not([data-not-push-state]):not(.close)", (event) =>
          return if event.altKey or event.ctrlKey or event.metaKey or event.shiftKey
          event.preventDefault()
          url = $(event.currentTarget).attr("href").replace "#{@_rootUrl}/",""
          Backbone.history.navigate url, trigger: true
