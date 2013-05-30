define [
  'jquery'
  'backbone'
  'handlebars'
  'underscore'
  'text!./templates/manageProduct.html'
  '../models/product'
  '../models/products'
  'backboneValidation'
], ($, Backbone, Handlebars, _, manageProductTemplate, Product, Products, Validation) ->
  class ManageProductView extends Backbone.Open.View
    events:
      'click #updateProduct':'_updateProduct'
      'click #confirmDeleteProduct':'_deleteProduct'
    @justCreated: false
    template: manageProductTemplate
    initialize: (opt) =>
      @model = opt.product
      @$el.html @template
      @bindings = @initializeBindings
        "#_id": "html:_id"
        "#slug": "html:slug"
        "#_id_holder": "toggle:_id"
        "#slug_holder": "toggle:slug"
        "#weight": "value:integerOr(weight)"
        "#height": "value:integerOr(height)"
        "#width": "value:integerOr(width)"
        "#depth": "value:integerOr(depth)"
        "#inventory": "value:integerOr(inventory)"
        "#price": "value:decimalOr(price)"
        "#hasInventory": "checked:hasInventory"
      Validation.bind @
    _updateProduct: =>
      if @model.isValid true
        @model.save @model.attributes, success: @_productUpdated, error: (model, xhr, options) -> console.log xhr
    _deleteProduct: =>
      @model.destroy wait:true, success: @_productDeleted, error: (model, xhr, options) -> console.log xhr
    _productUpdated: =>
      Backbone.history.navigate "store/#{@model.get('storeSlug')}", trigger: true
    _productDeleted: =>
      $('#confirmDeleteModal').modal 'hide'
      Backbone.history.navigate "store/#{@model.get('storeSlug')}", trigger: true
