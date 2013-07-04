_               = require 'underscore'
AccessDenied    = require '../errors/accessDenied'
values          = require '../helpers/values'

class Functions
  _auth: ->
    for fn in arguments
      do (fn) =>
        original = @[fn]
        @[fn] = (req, res) ->
          return res.redirect "/account/login?redirectTo=#{req.originalUrl}" unless req.loggedIn
          original.apply @, arguments

  _authSeller: ->
    for fn in arguments
      do (fn) =>
        original = @[fn]
        @[fn] = (req, res) ->
          throw new AccessDenied() unless req.loggedIn and req.user?.isSeller
          original.apply @, arguments

  _getSubdomain: (domain, host) ->
    return undefined if @env isnt 'production' and host is 'localhost'
    if host isnt domain and host isnt "www.#{domain}"
      subdomain = host.replace ".#{domain}", ''
    subdomain
  

module.exports = Functions
