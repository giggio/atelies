define [
  'backbone'
  './product'
], (Backbone, Product) ->
  class Products extends Backbone.Collection
    constructor: (@storeSlug) -> super()
    model: Product
    url: -> "/#{@storeSlug}/products"
