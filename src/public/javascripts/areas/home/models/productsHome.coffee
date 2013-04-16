define [
  'backbone'
  './productHome'
], (Backbone, ProductHome) ->
  class ProductsHome extends Backbone.Collection
    model: ProductHome
