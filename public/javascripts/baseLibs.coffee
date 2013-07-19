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
