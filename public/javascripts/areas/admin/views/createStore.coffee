define [
  'jquery'
  'backbone'
  'text!./templates/createStore.html'
  '../models/store'
  '../models/stores'
  './store'
  'backboneValidation'
], ($, Backbone, createStoreTemplate, Store, Stores, StoreView, Validation) ->
  class CreateStoreView extends Backbone.Open.View
    events:
      'click #createStore':'_createStore'
    template: createStoreTemplate
    initialize: ->
      @$el.html @template
      @model = new Store()
      @bindings = @initializeBindings()
      Validation.bind @
    _createStore: =>
      return unless @model.isValid true
      stores = new Stores()
      stores.add @model
      @model.save @model.attributes, success: (model) => @_storeCreated model, error: (model, xhr, opt) -> console.log 'error';throw message:'error when saving'
    _storeCreated: (store) =>
      adminStoresBootstrapModel.stores.push store.attributes
      @_goToStoreManagePage store
    _goToStoreManagePage: (store) =>
      StoreView.justCreated = true
      Backbone.history.navigate "store/#{store.get('slug')}", trigger: true
