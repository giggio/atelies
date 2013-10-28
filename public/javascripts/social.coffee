define [
  'gplus'
], (gplus) ->
  class Social
    @renderGooglePlus: ->
      gplus.go()
