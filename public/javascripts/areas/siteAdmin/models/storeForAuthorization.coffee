define [
  'backboneConfig'
], (Backbone) ->
  class StoreForAuthorization extends Backbone.Open.Model
    url: -> "siteAdmin/storesForAuthorization/#{@id}/isFlyerAuthorized/#{@get 'isFlyerAuthorized'}"
    authorize: (opt) -> @_authorizeOr true, opt
    unauthorize: (opt) -> @_authorizeOr false, opt
    _authorizeOr: (isFlyerAuthorized, opt) ->
      @save isFlyerAuthorized: isFlyerAuthorized,
        success: =>
          opt.success() if opt?.success?
          if isFlyerAuthorized
            @trigger 'authorized', @
          else
            @trigger 'unauthorized', @
