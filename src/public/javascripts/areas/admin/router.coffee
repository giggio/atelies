define [
  'backbone'
  'areas/admin/routes'
],
(Backbone, routes) ->
  class Router extends Backbone.Router
    routes:
      '': routes.admin
      'createStore': routes.createStore
      'manageStore/:storeSlug': routes.manageStore
    initialize: ->
      Backbone.history.start()
