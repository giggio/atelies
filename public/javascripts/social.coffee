define [
  'gplus'
  'facebook'
], (gplus, facebook) ->
  class Social
    @renderGooglePlus: ->
      gplus.go()
    @renderFacebook: ->
      facebook.XFBML.parse()
