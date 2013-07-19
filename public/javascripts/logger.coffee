define [
  'ga'
], (ga) ->
  class Logger
    constructor: (opt) ->
      @ga = opt?.ga or ga
      @ga 'create', 'UA-42524192-1', cookieDomain: 'atelies.com.br'
      #@ga 'create', 'UA-42524192-1', cookieDomain: 'none'
      @ga 'send', 'pageview'
    log: (info)->
      @ga 'send', 'event', info.category, info.action, info.label, info.field
