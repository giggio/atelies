define [
  'gplus'
  'facebook'
  'twitter'
], (gplus, facebook, twitter) ->
  class Social
    @renderGooglePlus: ->
      gplus.go()
    @renderFacebook: ->
    @renderTwitter: ->
      twitter.widgets.load()
