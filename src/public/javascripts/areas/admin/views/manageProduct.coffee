define [
  'jquery'
  'backbone'
  'handlebars'
  'underscore'
  'text!./templates/manageProduct.html'
  '../models/product'
  '../models/products'
  'backboneModelBinder'
  'backboneValidation'
], ($, Backbone, Handlebars, _, manageProductTemplate, Product, Products, ModelBinder, Validation) ->
  class ManageProductView extends Backbone.View
    events: 'click #updateProduct':'_updateProduct'
    @justCreated: false
    template: manageProductTemplate
    initialize: (opt) =>
      @product = opt.product
    render: =>
      @$el.html @template
      binder = new ModelBinder()
      bindings = @_initializeDefaultBindings()
      $.extend true, bindings, {}
      bindings.weight.converter = bindings.height.converter = bindings.width.converter = bindings.depth.converter = (direction, value) ->
        int = parseInt value
        if _.isNaN int then value else int
      bindings.price.converter = (direction, value) ->
        ft = parseFloat value
        if _.isNaN ft then value else ft
      binder.bind @product, @el, bindings
      @model = @product
      Validation.bind @
    _updateProduct: =>
      if @product.isValid true
        @product.save @product.attributes, success: @_productUpdated, error: (model, xhr, options) -> console.log xhr
    _productUpdated: =>
      Backbone.history.navigate "manageStore/#{@product.get('storeSlug')}", trigger: true
    _initializeDefaultBindings: ->
      attributeBindings = {}
      elsWithAttribute = $("[name]", @el)
      for el in elsWithAttribute
        name = $(el).attr 'name'
        attributeBindings[name] =
          selector: "[name='#{name}']"
      attributeBindings
