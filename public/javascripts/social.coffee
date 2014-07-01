define [
  'gplus'
  'facebook'
  'twitter'
], (gplus, facebook, twitter) ->
  class Social
    @renderAll: ->
      @renderFacebook()
      @renderTwitter()
      @renderGooglePlus()
    @renderGooglePlus: -> gplus.go()
    @renderFacebook: -> facebook.XFBML.parse()
    @renderTwitter: -> twitter.widgets.load()
