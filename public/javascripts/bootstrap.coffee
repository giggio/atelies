requirejs.config
  paths:
    jquery: 'lib/jquery/jquery'
    jqval: 'lib/jquery.validation/jquery.validate'
    underscore: 'lib/underscore/underscore'
    backbone: 'lib/backbone/backbone'
    handlebars: 'lib/handlebars/index'
    text: 'lib/requirejs-text/text'
    twitterBootstrap: 'lib/bootstrap/docs/assets/js/bootstrap'
    backboneValidation: 'lib/backbone-validation/dist/backbone-validation-amd'
    epoxy: 'lib/backbone.epoxy/index'
    caroufredsel: 'lib/carouFredSel/jquery.carouFredSel-6.2.1'
    imagesloaded: 'lib/imagesloaded/jquery.imagesloaded'
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
    'caroufredsel':
      deps: ['jquery']
      exports: '$.fn.carouFredSel'
    'imagesloaded':
      deps: ['jquery']
      exports: '$.fn.imagesLoaded'
    'jqval':
      deps: ['jquery']
      exports: '$.validator'
