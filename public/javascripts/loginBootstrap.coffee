require ['bootstrap'], ->
  require [
    './backboneConfig'
    './loginPopover'
    './jqueryValidationExt'
  ], ->
  require ['jquery', 'jqval'], ($) -> $ -> $('.validatable').validate()
