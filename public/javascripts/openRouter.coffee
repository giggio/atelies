define [
  'backbone'
  'underscore'
  './logger'
  './errorLogger'
  './seoLoadManager'
], (Backbone, _, Logger, ErrorLogger, SEOLoadManager) ->
  class Router extends Backbone.Router
    constructor: ->
      @logger = new Logger()
      super
    _createRoutes: (routes) ->
      @routes = routes
      @routes['redirect/:to'] = @redirect
      @_bindLoadingStartedToEveryRoute()
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
        el = $("section#app-container").parent()
        el.off 'click'
        el.on "click", "a:not([data-not-push-state])", (event) =>
          return if event.altKey or event.ctrlKey or event.metaKey or event.shiftKey
          event.preventDefault()
          url = $(event.currentTarget).prop("href").replace "#{location.protocol}//#{location.host}/#{@_rootUrl}/",""
          if url is "" then url = "home"
          Backbone.history.navigate url, trigger: true
          undefined
    redirect: (to) -> Backbone.history.navigate to, trigger: true
    logXhrError: (xhr, otherInfo) -> @logError xhr.responseText, otherInfo if xhr.status is 400
    logError: (message, otherInfo) -> ErrorLogger.logError @area, message, '', '', otherInfo
    _bindLoadingStartedToEveryRoute: ->
      for url, fn of @routes
        do (fn) =>
          @routes[url] = =>
            @_setLoadingStarted()
            fn.apply @, arguments
    _setLoadingStarted: -> @seoLoadManager = new SEOLoadManager().set()
    _setLoadingDone: -> @seoLoadManager.done()
