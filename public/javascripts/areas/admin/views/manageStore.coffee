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
      'click #confirmSetAutoCalculateShipping':'_confirmSetAutoCalculateShipping'
      'click #confirmUnsetAutoCalculateShipping':'_confirmUnsetAutoCalculateShipping'
    template: manageStoreTemplate
    initialize: (opt) ->
      @model = opt.store
      context = Handlebars.compile @template
      @$el.html context new: @model.id? is false, autoCalculateShipping: @model.get 'autoCalculateShipping'
      @bindings = @initializeBindings
        '#autoCalculateShipping':'checked:autoCalculateShipping'
        '#pagseguro':'checked:pagseguro'
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
    _confirmSetAutoCalculateShipping: -> @_setAutoCalculateShipping on
    _confirmUnsetAutoCalculateShipping: -> @_setAutoCalculateShipping off
    _setAutoCalculateShipping: (set) ->
      url = "/admin/store/#{@model.get('_id')}/setAutoCalculateShipping"
      url += if set then "On" else "Off"
      $.ajax
        url: url
        type: 'PUT'
        error: (xhr, text, error) ->
          return console.log error, xhr if xhr.status isnt 409
          $('#modalConfirmAutoCalculateShipping', @el).modal 'hide'
          $('#modalCannotAutoCalculateShipping', @el).modal 'show'
        success: (data, text, xhr) =>
          @model.set 'autoCalculateShipping', set
          $('#modalConfirmAutoCalculateShipping', @el).modal 'hide'
          @_storeCreated @model
