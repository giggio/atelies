define [
  'jquery'
  'underscore'
  'backboneConfig'
  'handlebars'
  '../models/productsHome'
  'text!./templates/_homeSearchResults.html'
], ($, _, Backbone, Handlebars, ProductsHome, homeProductsTemplate) ->
  class HomeSearchResultsView extends Backbone.Open.View
    events:
      'click #seeAllProducts':'_seeAllProducts'
      'click #seeAllStores':'_seeAllStores'
    template: homeProductsTemplate
    initialize: (opt) ->
      productGroups = @_group opt.products, "products"
      productGroups[0].isFirst = "isFirst" if productGroups.length > 0
      storeGroups = @_group opt.stores, "stores"
      storeGroups[0].isFirst = "isFirst" if storeGroups.length > 0
      context = Handlebars.compile @template
      @$el.html context productGroups: productGroups, hasProducts: opt.products.length > 0, hasMoreThanOneProductGroup: productGroups.length > 1, storeGroups: storeGroups, hasStores: opt.stores.length > 0, hasMoreThanOneStoreGroup: storeGroups.length > 1
      @$('.storesRow.isFirst,.productsRow.isFirst').addClass 'in'
      @$('.storesRow:not(.isFirst),.productsRow:not(.isFirst)').addClass 'hide'
    _group: (items, itemName) ->
      _.reduce items, (groups, item) ->
        if groups.length is 0 or _.last(groups)[itemName].length is 6
          group = {}
          group[itemName] = []
          groups.push group
        _.last(groups)[itemName].push item
        groups
      , []
    _seeAllStores: (e) -> @$('.storesRow:not(.isFirst)').toggleClass 'hide in'
    _seeAllProducts: (e) -> @$('.productsRow:not(.isFirst)').toggleClass 'hide in'
