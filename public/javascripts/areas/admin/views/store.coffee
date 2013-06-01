define [
  'jquery'
  'backbone'
  'handlebars'
  'underscore'
  'text!./templates/store.html'
  '../models/products'
], ($, Backbone, Handlebars, _, storeTemplate, Products) ->
  class StoreView extends Backbone.View
    @justCreated: false
    @justUpdated: false
    template: storeTemplate
    initialize: (opt) =>
      @products = opt.products
      @store = opt.store
    render: =>
      [justCreated, StoreView.justCreated, justUpdated, StoreView.justUpdated] = [StoreView.justCreated, off, StoreView.justUpdated, off]
      context = Handlebars.compile @template
      #@$el.html context store:@store, products:@products.toJSON(), justCreated:justCreated, justUpdated:justUpdated
      productGroups = @_groupProducts @products.toJSON()
      @$el.html context store:@store, productGroups:productGroups, justCreated:justCreated, justUpdated:justUpdated
    _groupProducts: (products) ->
      _.reduce products, (groups, product) ->
        if groups.length is 0 or _.last(groups).products.length is 6 then groups.push products:[]
        _.last(groups).products.push product
        groups
      , []
