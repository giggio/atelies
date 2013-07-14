require ['bootstrap'], ->
  require [
    './backboneConfig'
    './loginPopover'
    './jqueryValidationExt'
  ], ->
  require ['jquery', 'jqval'], ($) -> $ -> $('.validatable').validate
    highlight: (element) ->
      $(element).closest('.control-group').removeClass('success').addClass('error')
    success: (element) ->
      element.closest('.control-group').removeClass('error')
