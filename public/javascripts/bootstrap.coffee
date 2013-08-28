requirejs.config
  paths:
    jquery: 'lib/jquery/jquery'
    jqval: 'lib/jquery.validation/jquery.validate'
    underscore: 'lib/underscore/underscore'
    backbone: 'lib/backbone/backbone'
    handlebars: 'lib/handlebars/index'
    text: 'lib/requirejs-text/text'
    twitterBootstrap: 'lib/bootstrap/dist/js/bootstrap'
    backboneValidation: 'lib/backbone-validation/dist/backbone-validation-amd'
    epoxy: 'lib/backbone.epoxy/index'
    caroufredsel: 'lib/carouFredSel/jquery.carouFredSel-6.2.1'
    imagesloaded: 'lib/imagesloaded/jquery.imagesloaded'
    jqform: 'lib/jquery-form/jquery.form'
    jqexpander: 'lib/jquery.expander/jquery.expander'
    ga: '//www.google-analytics.com/analytics'
    showdown: 'lib/showdown/src/showdown'
    md5: 'lib/js-md5/js/md5'
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
    'jqform':
      deps: ['jquery']
      exports: '$.fn.ajaxSubmit'
    'ga':
      init: ->
        window.GoogleAnalyticsObject='ga' if window?
        return undefined
      exports: 'ga'
    'jqexpander':
      deps: ['jquery']
      exports: '$.fn.expander'
