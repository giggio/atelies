define [
  'jquery'
  'backbone'
  'handlebars'
  'adminStoresData'
  'text!./templates/admin.html'
], ($, Backbone, Handlebars, adminStoresData, adminTemplate) ->
  class AdminView extends Backbone.View
    template: adminTemplate
    initialize: (opt) =>
      @stores = if opt?.stores? then opt.stores else adminStoresData?.stores
    render: ->
      @$el.empty()
      context = Handlebars.compile @template
      @$el.html context stores:@stores, hasStores:@stores.length isnt 0
