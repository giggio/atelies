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
    @renderGooglePlus: ->
      gplus.go()
    @renderFacebook: ->
    @renderTwitter: ->
      twitter.widgets.load()
