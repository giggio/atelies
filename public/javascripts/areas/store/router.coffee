define [
  'backbone'
  'areas/store/routes'
],
(Backbone, routes) ->
  class Router extends Backbone.Router
    routes:
      '': routes.home
      'cart': routes.cart
      ':productSlug': routes.product
      'finishOrder/shipping': routes.finishOrderShipping
      'finishOrder/updateProfile': routes.finishOrderUpdateProfile
      'finishOrder/payment': routes.finishOrderPayment
    initialize: ->
      Backbone.history.start()
