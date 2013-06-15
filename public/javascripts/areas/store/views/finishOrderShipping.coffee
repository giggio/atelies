define [
  'jquery'
  'backbone'
  'handlebars'
  '../models/products'
  '../models/cart'
  'text!./templates/finishOrderShipping.html'
  './cartItem'
  '../../../converters'
], ($, Backbone, Handlebars, Products, Cart, finishOrderShippingTemplate, CartItemView, converters) ->
  class CartView extends Backbone.View
    events:
      'click #finishOrder':'finishOrder'
    template: finishOrderShippingTemplate
    initialize: (opt) =>
      @store = opt.store
      @cart = opt.cart
      @user = opt.user
    render: =>
      return if @_redirectIfUserNotSatisfied()
      context = Handlebars.compile @template
      @$el.html context user: @user
    finishOrder: ->
      Backbone.history.navigate 'finishOrder/payment', trigger: true
    _redirectIfUserNotSatisfied: ->
      if @user is undefined
        window.location = "/account/login?redirectTo=/#{@store.slug}%23finishOrder/shipping"
        return true
      ad = @user.deliveryAddress
      unless ad.street? and ad.state? and ad.city and ad.zip
        Backbone.history.navigate 'finishOrder/updateProfile', trigger: true
        return true
