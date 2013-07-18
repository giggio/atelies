define [
  'backboneConfig'
  'areas/store/routes'
],
(Backbone, routes) ->
  class Router extends Backbone.Open.Router
    logCategory: 'store'
    _routes: routes
    routes:
      '': routes.home
      'cart': routes.cart
      ':productSlug': routes.product
      'finishOrder/shipping': routes.finishOrderShipping
      'finishOrder/updateProfile': routes.finishOrderUpdateProfile
      'finishOrder/payment': routes.finishOrderPayment
      'finishOrder/summary': routes.finishOrderSummary
      'finishOrder/orderFinished': routes.finishOrderOrderFinished
      'searchProducts/:searchTerm': routes.searchProducts
