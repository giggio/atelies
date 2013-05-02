define [
  'jquery'
  'backbone'
  'handlebars'
  'text!./templates/createStore.html'
  '../models/store'
  '../models/stores'
  './manageStore'
], ($, Backbone, Handlebars, createStoreTemplate, Store, Stores, ManageStoreView) ->
  class CreateStoreView extends Backbone.View
    events:
      'click #createStore':'_createStore'
    template: createStoreTemplate
    render: ->
      @$el.empty()
      context = Handlebars.compile @template
      @$el.html context()
    _createStore: =>
      attrs = @_fromFields ['name', 'phoneNumber', 'city', 'state', 'otherUrl', 'banner']
      store = new Store attrs
      stores = new Stores()
      stores.add store
      store.save store.attributes, success: (model) => @_goToStoreManagePage model, error: (model, xhr, opt) -> console.log 'error';throw 'error when saving'
    _goToStoreManagePage: (store) =>
      ManageStoreView.justCreated = true
      Backbone.history.navigate "manageStore/#{store.get('slug')}", true
    _fromFields: (names) ->
      attrs = {}
      for name in names
        attrs[name] = @$("##{name}").val()
      attrs
