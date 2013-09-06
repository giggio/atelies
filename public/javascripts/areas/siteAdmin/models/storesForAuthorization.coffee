define [
  'underscore'
  'backboneConfig'
  './storeForAuthorization'
], (_, Backbone, StoreForAuthorization) ->
  class StoresForAuthorization extends Backbone.Collection
    initialize: (opt) ->
      @isFlyerAuthorized = if opt.status? then opt.status else ''
      @listenTo @, "sync", ->
        for store in @models
          @listenTo store, "authorized", _.bind @_storeAuthorized, @
          @listenTo store, "unauthorized", _.bind @_storeUnauthorized, @
    model: StoreForAuthorization
    url: -> "siteAdmin/storesForAuthorization/#{@isFlyerAuthorized}"
    _storeAuthorized: (store) ->
      @remove store unless @isFlyerAuthorized
      @trigger 'authorized', @, store
      @trigger 'authorizationChanged', @, store, "authorized"
    _storeUnauthorized: (store) ->
      @remove store if @isFlyerAuthorized
      @trigger 'unauthorized', @, store
      @trigger 'authorizationChanged', @, store, "unauthorized"
