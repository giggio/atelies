requirejs.config
  paths:
    jquery: 'lib/jquery.min'
    underscore: 'lib/underscore-min'
    backbone: 'lib/backbone-min'
    handlebars: 'lib/handlebars.min'
    text: 'lib/text'
    twitterBootstrap: 'lib/bootstrap.min'
    backboneModelBinder: 'lib/Backbone.ModelBinder'
    backboneValidation: 'lib/backbone-validation-amd-min'
  shim:
    'handlebars':
      deps: ['jquery']
      exports: 'Handlebars'
    'underscore':
      exports: '_'
    'backbone':
      deps: ['underscore', 'jquery', 'handlebars']
      exports: 'Backbone'
    'twitterBootstrap':
      deps: ['jquery']
      exports: '$.fn.popover'


if global? #nodejs only, needs to add jquery to global scope otherwise twitter bootstrap blows up
  window.$ = global.$ = requirejs 'jquery'
else
  requirejs [
    'app'
    './backboneConfig'
  ], (App) ->
    App.start()
