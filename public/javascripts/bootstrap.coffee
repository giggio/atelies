requirejs.config
  paths:
    jquery: 'lib/jquery/jquery.min'
    underscore: 'lib/underscore/underscore-min'
    backbone: 'lib/backbone/backbone-min'
    handlebars: 'lib/handlebars/handlebars'
    text: 'lib/requirejs-text/text'
    twitterBootstrap: 'lib/bootstrap/docs/assets/js/bootstrap.min'
    backboneModelBinder: 'lib/Backbone.ModelBinder/Backbone.ModelBinder.min'
    backboneValidation: 'lib/backbone-validation/dist/backbone-validation-amd-min'
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
