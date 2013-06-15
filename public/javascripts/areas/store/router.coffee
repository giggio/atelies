define [
  'backbone'
  'areas/store/routes'
],
(Backbone, routes) ->
  class Router extends Backbone.Open.Router
    _routes: routes
    routes:
      '': routes.home
      'cart': routes.cart
      ':productSlug': routes.product
      'finishOrder/shipping': routes.finishOrderShipping
      'finishOrder/updateProfile': routes.finishOrderUpdateProfile
      'finishOrder/payment': routes.finishOrderPayment
      'finishOrder/orderFinished': routes.finishOrderOrderFinished
