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
      'createProduct/:storeSlug': routes.createProduct
    initialize: ->
      Backbone.history.start()
