config = require '../config'
module.exports = (req, res, next) ->
  if req.secure or config.secureUrl is ''
    next()
  else
    res.redirect "#{config.secureUrl}#{req.originalUrl}"
