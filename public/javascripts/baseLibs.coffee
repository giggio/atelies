define [
  'jquery'
  './backboneConfig'
  './loginPopover'
  './jqueryValidationExt'
  'jqexpander'
], ($) ->
  $ ->
    $('.expander .answer').expander
      slicePoint: 160
      expandText: 'ler mais'
      userCollapseText: 'ler menos'
    $(document).ajaxSend (e, xhr, settings) ->
      $("#overlay").show() if settings.type isnt 'GET'
    $(document ).ajaxStop ->
      $("#overlay").hide()
