define [
  'jquery'
  'backbone'
  'handlebars'
  'text!./templates/admin.html'
], ($, Backbone, Handlebars, adminTemplate) ->
  class AdminView extends Backbone.View
    events:
      'click #createStore': -> Backbone.history.navigate 'createStore', true
    template: adminTemplate
    initialize: (opt) =>
      if opt?.stores?
        @stores = opt.stores
      else if adminStoresBootstrapModel?
        @stores = adminStoresBootstrapModel.stores
    render: ->
      @$el.empty()
      context = Handlebars.compile @template
      @$el.html context stores:@stores, hasStores:@stores.length isnt 0
