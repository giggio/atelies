define [
  'jquery'
  'backbone'
  'handlebars'
  '../models/products'
  '../models/cart'
  'text!./templates/cart.html'
  './cartItem'
], ($, Backbone, Handlebars, Products, Cart, cartTemplate, CartItemView) ->
  class CartView extends Backbone.View
    events:
      'click #clearCart':'clear'
    template: cartTemplate
    initialize: (opt) =>
      if storeBootstrapModel?
        @storeData = storeBootstrapModel
      else if opt?.storeData?
        @storeData = opt.storeData
      @cart = Cart.get(@storeData.store.slug)
    render: =>
      context = Handlebars.compile @template
      cartItems = Cart.get(@storeData.store.slug).items()
      @$el.html context cartItems: cartItems, store: @storeData.store, hasItems: cartItems.length isnt 0
      @renderCartItems()
    renderCartItems: =>
      for item in @cart.items()
        cartItemView = new CartItemView model: item
        cartItemView.render()
        $('#cartItems > tbody', @$el).append cartItemView.$el
        cartItemView.removed @remove
        cartItemView.changed @change
    remove: (item) =>
      @removeById item._id
    removeById: (id) =>
      @cart.removeById id
      @render()
    change: =>
      @cart.save()
    clear: =>
      @cart.clear()
      @render()
