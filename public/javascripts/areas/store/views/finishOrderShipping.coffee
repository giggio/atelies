define [
  'jquery'
  'underscore'
  'backboneConfig'
  'handlebars'
  '../models/products'
  '../models/cart'
  'text!./templates/finishOrderShipping.html'
  './cartItem'
  '../../../converters'
], ($, _, Backbone, Handlebars, Products, Cart, finishOrderShippingTemplate, CartItemView, converters) ->
  class CartView extends Backbone.View
    events:
      'click #finishOrder':'finishOrder'
      'click [name=shippingOptions]':'_shippingOptionSelected'
    template: finishOrderShippingTemplate
    initialize: (opt) =>
      @store = opt.store
      @cart = opt.cart
      @user = opt.user
      @hasShippingCosts = false
      @context = Handlebars.compile @template
    render: ->
      return if @_redirectIfUserNotSatisfied()
      @show()
      @_calculateShippingCosts()
    show: ->
      @$el.html @context user: @user, shippingOptions: @shippingOptions, hasShippingOptions: @hasShippingOptions, hasAutoCalculatedShipping: @store.autoCalculateShipping
    finishOrder: ->
      Backbone.history.navigate 'finishOrder/payment', trigger: true
    _redirectIfUserNotSatisfied: ->
      if @user is undefined
        window.location = "/account/login?redirectTo=/#{@store.slug}%23finishOrder/shipping"
        return true
      unless @user.verified
        window.location = "/account#userNotVerified"
        return true
      ad = @user.deliveryAddress
      unless ad.street? and ad.state? and ad.city and ad.zip
        Backbone.history.navigate 'finishOrder/updateProfile', trigger: true
        return true
    _calculateShippingCosts: ->
      unless @store.autoCalculateShipping
        @cart.setManualShipping()
        $('#finishOrder', @$el).removeAttr 'disabled'
        return
      if @cart.shippingSelected()
        @shippingOptions = $.extend true, [], @cart.shippingOptions()
        o.cost = converters.currency o.cost for o in @shippingOptions
        @hasShippingOptions = true
        selectedType = @cart.shippingOptionSelected().type
        @show()
        $("#shippingOptions_#{selectedType}", @$el).prop 'checked', true
        $('#finishOrder', @$el).removeAttr 'disabled'
        return
      data = items: _.map(@cart.items(), (i) -> _id: i._id, quantity: i.quantity)
      $.ajax
        url: "/shipping/#{@store.slug}"
        data: data
        type: 'POST'
        error: (xhr, text, error) -> console.log error
        success: (data, text, xhr) =>
          @cart.setShippingOptions data
          @shippingOptions = $.extend true, [], data
          o.cost = converters.currency o.cost for o in @shippingOptions
          @hasShippingOptions = true
          @show()
    _shippingOptionSelected: ->
      shippingType = $('[name=shippingOptions]:checked', @$el).attr('value')
      @cart.chooseShippingOption shippingType
      $('#finishOrder', @$el).removeAttr 'disabled'
