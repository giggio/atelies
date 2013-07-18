define [
  'backboneConfig'
], (Backbone) ->
  class ProductsSearch extends Backbone.Collection
    initialize: (opt) ->
      @searchTerm = opt.searchTerm
      @storeSlug = opt.storeSlug
    model: Backbone.Open.Model
    url: -> "/products/search/#{@storeSlug}/#{@searchTerm}"
