define [
  'jquery'
  'underscore'
  'backboneConfig'
  'handlebars'
  '../models/productsHome'
  'text!./templates/_homeStores.html'
  'caroufredsel'
  'imagesloaded'
], ($, _, Backbone, Handlebars, ProductsHome, homeStoresTemplate) ->
  class HomeStoresView extends Backbone.View
    template: homeStoresTemplate
    initialize: (opt) ->
      @stores = opt.stores
      @showStores()
    showStores: ->
      context = Handlebars.compile @template
      storeGroups = @_groupStores @stores
      @$el.html context storeGroups: storeGroups
    _groupStores: (stores) ->
      _.reduce stores, (groups, store) ->
        if groups.length is 0 or _.last(groups).stores.length is 4 then groups.push stores:[]
        _.last(groups).stores.push store
        groups
      , []
