define [
  'underscore'
  'backboneConfig'
  './storeForAuthorization'
], (_, Backbone, StoreForAuthorization) ->
  class StoresForAuthorization extends Backbone.Collection
    url: -> "/api/siteAdmin/storesForAuthorization#{@isFlyerAuthorizedString}"
    initialize: (opt) ->
      @isFlyerAuthorizedString = if opt.status? then "/#{opt.status}" else ''
      @isFlyerAuthorized = opt.status
      @listenTo @, "sync", ->
        for store in @models
          @listenTo store, "authorized", _.bind @_storeAuthorized, @
          @listenTo store, "unauthorized", _.bind @_storeUnauthorized, @
    model: StoreForAuthorization
    _storeAuthorized: (store) ->
      @remove store if !@isFlyerAuthorized or !@isFlyerAuthorized?
      @trigger 'authorized', @, store
      @trigger 'authorizationChanged', @, store, "authorized"
    _storeUnauthorized: (store) ->
      @remove store if @isFlyerAuthorized or !@isFlyerAuthorized?
      @trigger 'unauthorized', @, store
      @trigger 'authorizationChanged', @, store, "unauthorized"
