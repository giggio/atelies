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
      'manageProduct/:storeSlug/:productId': routes.manageProduct
    initialize: ->
      Backbone.history.start()
