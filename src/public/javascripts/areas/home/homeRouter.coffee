define [
  'backbone'
  'areas/home/homeRoutes'
],
(Backbone, routes) ->
  class HomeRouter extends Backbone.Router
    routes:
      '': routes.home
      'home': routes.home
    initialize: ->
      Backbone.history.start()
