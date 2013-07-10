require ['bootstrap'], ->
  require [
    './backboneConfig'
    './loginPopover'
    './jqueryValidationExt'
  ], ->
  require ['areas/store/router'], (Router) -> new Router()
