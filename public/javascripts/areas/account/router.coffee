define [
  'backbone'
  'areas/account/routes'
],
(Backbone, routes) ->
  class Router extends Backbone.Open.Router
    _routes: routes
    routes:
      '': routes.home
      'orders': routes.orders
