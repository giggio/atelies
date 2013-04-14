define [
  'backbone'
  'areas/home/routes'
],
(Backbone, routes) ->
  class Router extends Backbone.Router
    routes:
      '': routes.home
      'home': routes.home
    initialize: ->
      Backbone.history.start()
