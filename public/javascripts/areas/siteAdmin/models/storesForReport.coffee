define [
  'underscore'
  'backboneConfig'
], (_, Backbone) ->
  class StoresForReport extends Backbone.Collection
    url: -> "/api/siteAdmin/stores"
    model: Backbone.Open.Model
