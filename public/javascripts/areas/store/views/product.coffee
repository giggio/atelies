define [
  'jquery'
  'backboneConfig'
  'handlebars'
  'showdown'
  '../models/products'
  'text!./templates/product.html'
  '../models/cart'
], ($, Backbone, Handlebars, Showdown, Products, productTemplate, Cart) ->
  class ProductView extends Backbone.Open.View
    template: productTemplate
    initialize: (opt) ->
      @markdown = new Showdown.converter()
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
      @cart.addItem _id: @product.get('_id'), name: @product.get('name'), picture: @product.get('picture'), url: @product.get('url'), price: @product.get('price'), shippingApplies: @product.get('shippingApplies')
      Backbone.history.navigate '#cart', trigger: true
    render: ->
      @$el.empty()
      context = Handlebars.compile @template
      @delegateEvents()
      attr = @product.attributes
      attr.tags = attr.tags.split(', ')
      if attr.description?
        description = @markdown.makeHtml attr.description
      @$el.html context product: attr, store: @store, canPurchase: @canPurchase, description: description
