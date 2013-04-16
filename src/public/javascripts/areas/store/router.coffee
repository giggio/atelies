define [
  'backbone'
  'areas/store/routes'
],
(Backbone, routes) ->
  class Router extends Backbone.Router
    routes:
      '': routes.home
      ':productSlug': routes.product
    initialize: ->
      Backbone.history.start()
