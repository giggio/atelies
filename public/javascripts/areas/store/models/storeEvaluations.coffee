define [
  'backboneConfig'
], (Backbone) ->
  class StoreEvaluations extends Backbone.Collection
    initialize: (opt) ->
      @storeId = opt.storeId
    model: Backbone.Open.Model
    url: -> "/api/stores/#{@storeId}/evaluations"
