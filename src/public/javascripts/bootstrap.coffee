require.config
  paths:
    jquery: 'lib/jquery.min'
    Underscore: 'lib/underscore-min'
    Backbone: 'lib/backbone-min'
    Handlebars: 'lib/handlebars.min'
    text: 'lib/text'
    TwitterBootstrap: 'lib/bootstrap.min'

  shim:
    'jQueryUI':
      deps: ['jquery']
    'Handlebars':
      deps: ['jquery']
      exports: 'Handlebars'
    'Underscore':
      exports: '_'
    'Backbone':
      deps: ['Underscore', 'jquery', 'Handlebars']
      exports: 'Backbone'
    'TwitterBootstrap':
      deps: ['jquery']
      exports: '$.fn.popover'

require [
  'Handlebars'
  'router'
  'TwitterBootstrap'
], (Handlebars, router) ->
  Handlebars.registerHelper 'formataData', (valor) ->
    return "" if not valor
    try
      data = new Date(valor)
      (data.getUTCMonth() + 1) + "/" + data.getUTCDate() + "/" + data.getUTCFullYear()
    catch error
      valor
  new router()
