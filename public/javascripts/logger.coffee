define [
  'ga'
], (ga) ->
  class Logger
    constructor: (opt) ->
      @ga = opt?.ga or ga
      @ga 'create', 'UA-42524192-1', 'atelies.com.br'
      @ga 'send', 'pageview'
    log: (info)->
      @ga 'send', info.event, info.category, info.action, info.label
