define [
  'backbone'
], (Backbone) ->
  class Router extends Backbone.Router
    constructor: ->
      @routes['redirect/:to'] = @_routes.redirect
      super()
    initialize: ->
      Backbone.history.start()
      @_redirectIfRequested()
    _redirectIfRequested: ->
      if boostrapedRedirect?
        Backbone.history.navigate boostrapedRedirect, trigger: true
