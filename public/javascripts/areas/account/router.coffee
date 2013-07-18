define [
  'backboneConfig'
  'areas/account/routes'
],
(Backbone, routes) ->
  class Router extends Backbone.Open.Router
    _routes: routes
    routes:
      '': routes.home
      'orders': routes.orders
      'orders/:orderId': routes.order
      'userNotVerified': routes.userNotVerified
