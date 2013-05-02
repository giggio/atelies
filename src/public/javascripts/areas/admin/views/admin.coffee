define [
  'jquery'
  'backbone'
  'handlebars'
  'text!./templates/admin.html'
], ($, Backbone, Handlebars, adminTemplate) ->
  class AdminView extends Backbone.View
    template: adminTemplate
    initialize: (opt) =>
      @stores = opt.stores if opt?.stores?
    render: ->
      @$el.empty()
      context = Handlebars.compile @template
      @$el.html context stores:@stores, hasStores:@stores.length isnt 0
