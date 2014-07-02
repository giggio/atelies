define [
  'jquery'
  'backboneConfig'
  'handlebars'
  '../models/products'
  '../models/cart'
  'text!./templates/cart.html'
  './cartItem'
  '../../../converters'
], ($, Backbone, Handlebars, Products, Cart, cartTemplate, CartItemView, converters) ->
  class CartView extends Backbone.Open.View
    events:
      'click #clearCart':'clear'
      'click #finishOrderCart':'finishOrder'
    template: cartTemplate
    initialize: (opt) =>
      @store = opt.store
      @cart = Cart.get(@store.slug)
    render: =>
      context = Handlebars.compile @template
      cartItems = Cart.get(@store.slug).items()
      @$el.html context cartItems: cartItems, store: @store, hasItems: cartItems.length isnt 0
      @renderCartItems()
      document.title = "#{@store.name} - Carrinho"
      super
    renderCartItems: =>
      items = @cart.items()
      for item in items
        item.url = '/' + item.url if item.url.substr(0, 1) isnt '/'
        cartItemView = new CartItemView cartItem: item
        $('#cartItems > tbody', @$el).append cartItemView.$el
        cartItemView.removed @remove
        cartItemView.changed @change
      $("#totalPrice", @$el).html converters.currency @cart.totalPrice()
    remove: (item) =>
      @removeById item._id
    removeById: (id) =>
      @cart.removeById id
      @render()
    change: =>
      @cart.save()
      @render()
    clear: =>
      @cart.clear()
      @render()
    finishOrder: ->
      Backbone.history.navigate '#finishOrder/shipping', trigger: true
