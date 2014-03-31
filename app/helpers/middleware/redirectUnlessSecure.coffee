config = require '../config'
module.exports = (req, res, next) ->
  if req.secure or config.environment isnt 'production'
    next()
  else
    res.redirect "#{config.secureUrl}#{req.originalUrl}"
