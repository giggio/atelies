define [
  'backboneConfig'
], (Backbone) ->
  class StoreEvaluations extends Backbone.Collection
    initialize: (opt) ->
      @storeSlug = opt.storeSlug
    model: Backbone.Open.Model
    url: -> "/stores/#{@storeSlug}/evaluations"
