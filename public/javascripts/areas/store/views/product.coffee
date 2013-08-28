define [
  'jquery'
  'backboneConfig'
  'handlebars'
  'showdown'
  'md5'
  '../models/products'
  'text!./templates/product.html'
  '../models/cart'
], ($, Backbone, Handlebars, Showdown, md5, Products, productTemplate, Cart) ->
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
      description = @markdown.makeHtml attr.description if attr.description?
      if attr.comments?
        for c in attr.comments
          c.niceDate = @createNiceDate c.date
          c.gravatarUrl = "https://secure.gravatar.com/avatar/#{md5(c.userEmail.toLowerCase())}?d=mm&r=pg&s=50"
          c.body = @markdown.makeHtml c.body
      @$el.html context product: attr, store: @store, canPurchase: @canPurchase, description: description, hasComments: attr.comments?.length > 0
    createNiceDate: (date) ->
      date = new Date(date) if typeof date is 'string'
      date = date.getTime() unless typeof date is 'number'
      diffInMils = new Date().getTime() - date
      diffInMins = diffInMils / 1000 / 60
      diffInHours = diffInMins / 60
      diffInDays = diffInHours / 24
      switch
        when diffInMins < 0 then 'no futuro'
        when diffInMins < 1 then 'agorinha'
        when diffInMins < 2 then 'a um minuto'
        when diffInMins < 16 then 'a quinze minutos'
        when diffInMins < 45 then 'a meia hora'
        when diffInMins < 75 then 'a uma hora'
        when diffInMins < 140 then 'a duas horas'
        when diffInHours < 24 then "a #{Math.floor diffInHours, 0} horas"
        else "a #{Math.floor diffInDays, 0} dias"
