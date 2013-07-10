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
      if @product?.get('hasInventory')
        @canPurchase = @product?.get('inventory') > 0
      else
        @canPurchase = true
    events: ->
      if @product?
        "click #product > #purchaseItem": 'purchase'
    purchase: ->
      return unless @canPurchase
      @cart = Cart.get(@store.slug)
      @cart.addItem _id: @product.get('_id'), name: @product.get('name'), picture: @product.get('picture'), url: @product.get('url'), price: @product.get('price')
      Backbone.history.navigate '#cart', trigger: true
    render: ->
      @$el.empty()
      context = Handlebars.compile @template
      @delegateEvents()
      attr = @product.attributes
      attr.tags = attr.tags.split(', ')
      @$el.html context product: attr, store: @store, canPurchase: @canPurchase
