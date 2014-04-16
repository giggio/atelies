define [
  'jquery'
  'underscore'
  'backboneConfig'
  'handlebars'
  'text!./templates/storesReport.html'
], ($, _, Backbone, Handlebars, storesReportTemplate) ->
  class ApproveStoresView extends Backbone.Open.View
    template: storesReportTemplate
    initialize: (opt) ->
      @stores = opt.stores.toJSON()
    render: ->
      context = Handlebars.compile @template
      for store in @stores
        store.categories = _.reduce(store.categories, ((a, c) -> a += ", #{c}"), "").replace ", ", ""
        store.hasEvaluations = store.numberOfEvaluations > 0
      @$el.html context stores: @stores
