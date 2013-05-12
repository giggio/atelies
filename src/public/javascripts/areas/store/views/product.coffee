define [
  'jquery'
  'backbone'
  'handlebars'
  '../models/products'
  'text!./templates/product.html'
  '../models/cart'
], ($, Backbone, Handlebars, Products, productTemplate, Cart) ->
  class ProductView extends Backbone.View
    template: productTemplate
    initialize: (opt) ->
      @store = opt.store
      @product = opt.product
    events: ->
      if @product?
        events = {}
        events["click #product#{@product.get('_id')} > #purchaseItem"] = 'purchase'
        events
    purchase: ->
      @cart = Cart.get(@store.slug)
      @cart.addItem _id: @product.get('_id'), name: @product.get('name')
      Backbone.history.navigate '#cart', trigger: true
    render: ->
      @$el.empty()
      context = Handlebars.compile @template
      @delegateEvents()
      @$el.html context product: @product.attributes, store: @store
