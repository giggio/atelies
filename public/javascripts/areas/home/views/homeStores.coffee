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
  class HomeStoresView extends Backbone.Open.View
    template: homeStoresTemplate
    initialize: (opt) ->
      @stores = opt.stores
      @showStores()
    showStores: ->
      context = Handlebars.compile @template
      storesWithFlyer = _.filter @stores, (store) -> store.flyer? and /./.test store.flyer
      storesWithoutFlyer = _.filter @stores, (store) -> !store.flyer? or store.flyer is ''
      storeGroups = @_groupStores storesWithFlyer
      @$el.html context hasStores: @stores.length > 0, storeGroups: storeGroups, hasStoresWithFlyer: storesWithFlyer.length > 0, storesWithoutFlyer: storesWithoutFlyer, hasStoreWithoutFlyer: storesWithoutFlyer.length > 0
    _groupStores: (stores) ->
      _.reduce stores, (groups, store) ->
        if groups.length is 0 or _.last(groups).stores.length is 4 then groups.push stores:[]
        _.last(groups).stores.push store
        groups
      , []
