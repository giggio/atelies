define [
  'backboneConfig'
  'areas/store/routes'
],
(Backbone, Routes) ->
  class Router extends Backbone.Open.Router
    constructor: ->
      @_routes = new Routes()
      @routes =
        '': @_routes.home
        'cart': @_routes.cart
        'evaluations': @_routes.evaluations
        ':productSlug': @_routes.product
        'finishOrder/shipping': @_routes.finishOrderShipping
        'finishOrder/updateProfile': @_routes.finishOrderUpdateProfile
        'finishOrder/payment': @_routes.finishOrderPayment
        'finishOrder/summary': @_routes.finishOrderSummary
        'finishOrder/orderFinished': @_routes.finishOrderOrderFinished
        'searchProducts/:searchTerm': @_routes.searchProducts
      super
    logCategory: 'store'
