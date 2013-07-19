define [
  'ga'
], (ga) ->
  class Logger
    constructor: (opt) ->
      @ga = opt?.ga or ga
      if DEBUG
        @ga 'create', 'UA-42524192-1', cookieDomain: 'none'
      else
        @ga 'create', 'UA-42524192-1', cookieDomain: 'atelies.com.br'
      @ga 'send', 'pageview'
    log: (info)->
      @ga 'send', 'event', info.category, info.action, info.label, info.field
