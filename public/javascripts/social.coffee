define [
  'gplus'
  'facebook'
  'twitter'
], (gplus, facebook, twitter) ->
  class Social
    @renderGooglePlus: ->
      gplus.go()
    @renderFacebook: ->
      facebook.XFBML.parse()
    @renderTwitter: ->
      twitter.widgets.load()
