define [
  'backbone'
  'areas/admin/routes'
],
(Backbone, routes) ->
  class Router extends Backbone.Router
    routes:
      '': routes.admin
    initialize: ->
      Backbone.history.start()
