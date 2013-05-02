define [
  'jquery'
  'backbone'
  'handlebars'
  'text!./templates/manageStore.html'
], ($, Backbone, Handlebars, manageStoreTemplate) ->
  class ManageStoreView extends Backbone.View
    @justCreated: false
    template: manageStoreTemplate
    initialize: (opt) =>
      @storeSlug = opt.storeSlug
    render: =>
      context = Handlebars.compile @template
      @$el.html context storeSlug:@storeSlug, justCreated:ManageStoreView.justCreated
      ManageStoreView.justCreated = off
