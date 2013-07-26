define [
  'jquery'
  'underscore'
  'backboneConfig'
  'handlebars'
  '../models/productsHome'
  'text!./templates/_homeProductsSearchResults.html'
], ($, _, Backbone, Handlebars, ProductsHome, homeProductsTemplate) ->
  class HomeProductsView extends Backbone.Open.View
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
