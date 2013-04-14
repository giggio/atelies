define [
  'backbone'
  './ProductHome'
], (Backbone, ProductHome) ->
  class ProductsHome extends Backbone.Collection
    model: ProductHome
