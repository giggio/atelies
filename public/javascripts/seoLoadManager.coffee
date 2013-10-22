define ->
  class SEOLoadManager
    set: ->
      window.prerenderReady = off
      @
    done: ->
      window.prerenderReady = on
      @
