define [
  'jquery'
  'backboneConfig'
  './product'
], ($, Backbone, Product) ->
  class Products extends Backbone.Collection
    initialize: (models, opt) ->
      [opt, models] = [models, opt] unless $.isArray models
      @storeSlug = opt.storeSlug
    model: Product
    url: -> "/admin/#{@storeSlug}/products"
