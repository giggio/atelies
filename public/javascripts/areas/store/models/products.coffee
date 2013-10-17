define [
  'backboneConfig'
  './product'
], (Backbone, Product) ->
  class Products extends Backbone.Collection
    constructor: (@storeSlug, @productSlug) -> super()
    model: Product
    url: -> "/api/#{@storeSlug}/#{@productSlug}"
