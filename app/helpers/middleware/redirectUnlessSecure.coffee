config = require '../config'
module.exports = (req, res, next) ->
  if req.secure
    next()
  else
    res.redirect "https://#{config.baseDomain}#{req.originalUrl}"
