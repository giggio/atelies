express       = require "express"
express.response.renderWithCode = (code, view, locals) ->
  @status code
  @render view, locals
