define [
  'backbone'
  'routes'
],
(Backbone, routes) ->
  class App extends Backbone.Router
    routes:
      '': routes.home
      'home': routes.home
    initialize: ->
      Backbone.history.start()
