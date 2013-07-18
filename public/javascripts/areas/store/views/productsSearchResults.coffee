define [
  'jquery'
  'underscore'
  'backboneConfig'
  'handlebars'
  'text!./templates/_productsSearchResults.html'
], ($, _, Backbone, Handlebars, homeProductsTemplate) ->
  class ProductsSearchResultsView extends Backbone.View
    template: homeProductsTemplate
    initialize: (opt) ->
      @products = opt.products
      @showProducts()
    showProducts: ->
      context = Handlebars.compile @template
      productGroups = @_groupProducts @products
      @$el.html context productGroups: productGroups
    _groupProducts: (products) ->
      _.reduce products, (groups, product) ->
        if groups.length is 0 or _.last(groups).products.length is 6 then groups.push products:[]
        _.last(groups).products.push product
        groups
      , []
