define [
  'jquery'
  'backbone'
  'text!./templates/createStore.html'
  '../models/store'
  '../models/stores'
  './manageStore'
  'backboneModelBinder'
  'backboneValidation'
], ($, Backbone, createStoreTemplate, Store, Stores, ManageStoreView, ModelBinder, Validation) ->
  class CreateStoreView extends Backbone.View
    events:
      'click #createStore':'_createStore'
    template: createStoreTemplate
    render: ->
      @$el.html @template
      @model = new Store()
      bindings = @_initializeDefaultBindings()
      binder = new ModelBinder()
      binder.bind @model, @el, bindings
      Validation.bind @
    _createStore: =>
      return unless @model.isValid true
      attrs = @_fromFields ['name', 'phoneNumber', 'city', 'state', 'otherUrl', 'banner']
      store = new Store attrs
      stores = new Stores()
      stores.add store
      store.save store.attributes, success: (model) => @_storeCreated model, error: (model, xhr, opt) -> console.log 'error';throw message:'error when saving'
    _storeCreated: (store) =>
      adminStoresBootstrapModel.stores.push store.attributes
      @_goToStoreManagePage store
    _goToStoreManagePage: (store) =>
      ManageStoreView.justCreated = true
      Backbone.history.navigate "manageStore/#{store.get('slug')}", trigger: true
    _fromFields: (names) ->
      attrs = {}
      for name in names
        attrs[name] = @$("##{name}").val()
      attrs
    _initializeDefaultBindings: ->
      attributeBindings = {}
      elsWithAttribute = $("[name]", @el)
      for el in elsWithAttribute
        name = $(el).attr 'name'
        attributeBindings[name] =
          selector: "[name='#{name}']"
      attributeBindings
