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
    events: ->
      if @product?
        events = {}
        events["click #product#{@product.get('_id')} > #purchaseItem"] = 'purchase'
        events
    purchase: ->
      @cart = Cart.get(@store.slug)
      @cart.addItem _id: @product.get('_id'), name: @product.get('name')
      Backbone.history.navigate '#cart', trigger: true
    renderWithStore: (store, slug) ->
      @$el.empty()
      products = new Products store.slug, slug
      products.fetch
        reset: true
        success: =>
          context = Handlebars.compile @template
          @product = products.first()
          @delegateEvents()
          @$el.html context product: @product.attributes, store: store
        error: (collection, response, opt) =>
          console.error "Error fetching product with slug #{slug}"
          console.error collection
          console.error response
          console.error opt
          console.error opt?.xhr.error

    render: (slug) ->
      if @store?
        @renderWithStore @store, slug
      else
        require ['storeData'], (storeData) =>
          @store = storeData.store
          @renderWithStore storeData.store, slug
      return
      require ['storeData'], (storeData) =>
        @$el.empty()
        products = new Products storeData.store.slug, slug
        products.fetch
          reset: true
          success: =>
            context = Handlebars.compile @template
            @product = products.first()
            @delegateEvents()
            @$el.html context product: @product.attributes, store: storeData.store
          error: (collection, response, opt) =>
            console.error "Error fetching product with slug #{slug}"
            console.error collection
            console.error response
            console.error opt
            console.error opt?.xhr.error
