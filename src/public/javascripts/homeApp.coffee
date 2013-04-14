define [
  'backbone'
  'routes'
],
(Backbone, routes) ->
  class HomeApp extends Backbone.Router
    routes:
      '': routes.home
      'home': routes.home
    initialize: ->
      Backbone.history.start()
