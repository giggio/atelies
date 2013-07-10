require ['bootstrap'], ->
  require [
    './backboneConfig'
    './loginPopover'
    './jqueryValidationExt'
  ], ->
  require ['areas/admin/router'], (Router) -> new Router()
