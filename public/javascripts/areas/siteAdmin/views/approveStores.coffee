define [
  'jquery'
  'backboneConfig'
  'handlebars'
  './approveStore'
  'text!./templates/approveStores.html'
  'text!./templates/approveStoresRow.html'
], ($, Backbone, Handlebars, ApproveStoreView, approveStoresTemplate, approveStoresRowTemplate) ->
  class ApproveStoresView extends Backbone.Open.View
    template: approveStoresTemplate
    storesRowTemplate: approveStoresRowTemplate
    initialize: (opt) ->
      @stores = opt.stores
      @listenTo @stores, "authorizationChanged", @_authorizationChanged
    render: ->
      storeGroups = @_groupStores @stores.models
      context = Handlebars.compile @template
      @$el.html context hasStores: @stores.length > 0
      storesEl = @$ "#stores"
      for group in storeGroups
        storesEl.append @storesRowTemplate
        storeRowEl = @$ "#stores .storesRow:last-child"
        for store in group.stores
          storeView = new ApproveStoreView store:store
          storeRowEl.append storeView.el
      super
    _groupStores: (stores) ->
      _.reduce stores, (groups, store) ->
        if groups.length is 0 or _.last(groups).stores.length is 4 then groups.push stores:[]
        _.last(groups).stores.push store
        groups
      , []
    _authorizationChanged: (collection, model, authorizationChange) ->
      @render()
      if authorizationChange is "authorized"
        @showDialog "Autorizado com sucesso.", "Autorização"
      else
        @showDialog "Reprovado com sucesso.", "Autorização"
