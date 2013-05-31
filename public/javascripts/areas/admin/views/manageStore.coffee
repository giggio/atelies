define [
  'jquery'
  'backbone'
  'handlebars'
  'text!./templates/manageStore.html'
  './store'
  'backboneValidation'
], ($, Backbone, Handlebars, manageStoreTemplate, StoreView, Validation) ->
  class ManageStoreView extends Backbone.Open.View
    events:
      'click #updateStore':'_updateStore'
    template: manageStoreTemplate
    initialize: (opt) ->
      @model = opt.store
      context = Handlebars.compile @template
      @$el.html context new: @model.id? is false
      @bindings = @initializeBindings()
      Validation.bind @
    _updateStore: =>
      return unless @model.isValid true
      @model.save @model.attributes, success: (model) => @_storeCreated model, error: (model, xhr, opt) -> console.log 'error';throw message:'error when saving'
    _storeCreated: (store) =>
      update = false
      existingStore = _.findWhere adminStoresBootstrapModel.stores, _id: store.get('_id')
      if existingStore?
        update = true
        index = adminStoresBootstrapModel.stores.indexOf existingStore
        adminStoresBootstrapModel.stores.splice index, 1
      adminStoresBootstrapModel.stores.push store.attributes
      @_goToStoreManagePage store, update
    _goToStoreManagePage: (store, update) =>
      StoreView.justCreated = !update
      StoreView.justUpdated = update
      Backbone.history.navigate "store/#{store.get('slug')}", trigger: true
