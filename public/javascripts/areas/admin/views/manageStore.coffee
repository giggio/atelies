define [
  'jquery'
  'backbone'
  'text!./templates/manageStore.html'
  '../models/store'
  '../models/stores'
  './store'
  'backboneValidation'
], ($, Backbone, manageStoreTemplate, Store, Stores, StoreView, Validation) ->
  class ManageStoreView extends Backbone.Open.View
    events:
      'click #updateStore':'_updateStore'
    template: manageStoreTemplate
    initialize: ->
      @$el.html @template
      @model = new Store()
      @bindings = @initializeBindings()
      Validation.bind @
    _updateStore: =>
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
