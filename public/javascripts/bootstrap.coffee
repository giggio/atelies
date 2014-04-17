requirejs.config
  paths:
    jquery: 'lib/jquery/jquery'
    jqval: 'lib/jquery.validation/jquery.validate'
    underscore: 'lib/underscore/underscore'
    backbone: 'lib/backbone/backbone'
    handlebars: 'lib/handlebars/handlebars'
    text: 'lib/requirejs-text/text'
    twitterBootstrap: 'lib/bootstrap/dist/js/bootstrap'
    backboneValidation: 'lib/backbone-validation/dist/backbone-validation-amd'
    epoxy: 'lib/backbone.epoxy/backbone.epoxy'
    caroufredsel: 'lib/carouFredSel/jquery.carouFredSel-6.2.1'
    imagesloaded: 'lib/imagesloaded/jquery.imagesloaded'
    jqform: 'lib/jquery-form/jquery.form'
    jqexpander: 'lib/jquery.expander/jquery.expander'
    ga: [ '//www.google-analytics.com/analytics' , 'lib/ga/index' ]
    gplus: [ '//apis.google.com/js/plusone', 'lib/gplus/index' ]
    facebook: [ '//connect.facebook.net/pt_BR/all', 'lib/facebook/index' ]
    twitter: [ '//platform.twitter.com/widgets', 'lib/twitter/index' ]
    showdown: 'lib/showdown/src/showdown'
    md5: 'lib/js-md5/js/md5'
    swag: 'lib/swag/lib/swag'
    jrating: 'lib/jrating/jquery/jRating.jquery'
    select2en: 'lib/select2/select2'
    select2: 'lib/select2/select2_locale_pt-BR'
    'boostrap-sortable': 'lib/bootstrap-sortable/Scripts/bootstrap-sortable'
    moment: 'lib/moment/moment'
  shim:
    'boostrap-sortable':
      deps: [ 'jquery', 'moment' ]
      exports: '$.fn.TinySort'
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
    'gplus':
      init: ->
        window.___gcfg = {lang: 'pt-BR'}
        return undefined
      exports: 'window.gapi.plusone'
    'facebook':
      init: ->
        FB.init
          appId:'618886944811863'
          channelUrl:'//www.atelies.com.br/facebookChannel.html'
          status:true
          xfbml:true
        return undefined
      exports: 'FB'
    'twitter':
      exports: 'twttr'
    'jqexpander':
      deps: ['jquery']
      exports: '$.fn.expander'
    'swag':
      deps: ['handlebars']
      exports: 'window.Swag'
    'jrating':
      deps: [ 'jquery' ]
      exports: '$.fn.jRating'
    'select2':
      deps: [ 'select2en' ]
    'select2en':
      deps: [ 'jquery' ]
      exports: '$.fn.select2'

remoteComponents = if DEBUG
  ga: [ 'lib/ga/index' ]
  gplus: [ 'lib/gplus/index' ]
  facebook: [ 'lib/facebook/index' ]
  twitter: [ 'lib/twitter/index' ]
else
  ga: [ '//www.google-analytics.com/analytics' , 'lib/ga/index' ]
  gplus: [ '//apis.google.com/js/plusone', 'lib/gplus/index' ]
  facebook: [ '//connect.facebook.net/pt_BR/all', 'lib/facebook/index' ]
  twitter: [ '//platform.twitter.com/widgets', 'lib/twitter/index' ]

requirejs.config paths:remoteComponents
