define [
  'jquery'
  'backbone'
  'handlebars'
  'underscore'
  'text!./templates/manageStore.html'
], ($, Backbone, Handlebars, _, manageStoreTemplate) ->
  class ManageStoreView extends Backbone.View
    @justCreated: false
    template: manageStoreTemplate
    initialize: (opt) =>
      @store = _.findWhere adminStoresBootstrapModel.stores, slug: opt.storeSlug
    render: =>
      context = Handlebars.compile @template
      @$el.html context store:@store, justCreated:ManageStoreView.justCreated
      ManageStoreView.justCreated = off
