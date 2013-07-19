require ['bootstrap'], ->
  require [
    './baseLibs'
  ], ->
  require ['jquery', 'jqval'], ($) -> $ -> $('.validatable').validate
    highlight: (element) ->
      $(element).closest('.control-group').removeClass('success').addClass('error')
    success: (element) ->
      element.closest('.control-group').removeClass('error')
