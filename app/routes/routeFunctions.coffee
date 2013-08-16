_               = require 'underscore'
AccessDenied    = require '../errors/accessDenied'
values          = require '../helpers/values'
config          = require '../helpers/config'
Err             = require '../models/error'

module.exports = class RouteFunctions
  _auth: ->
    for fn in arguments
      do (fn) =>
        original = @[fn]
        @[fn] = (req, res) ->
          return res.redirect "#{config.secureUrl}/account/login?redirectTo=#{req.originalUrl}" unless req.loggedIn
          original.apply @, arguments

  _authSeller: ->
    for fn in arguments
      do (fn) =>
        original = @[fn]
        @[fn] = (req, res) ->
          throw new AccessDenied() unless req.loggedIn and req.user?.isSeller
          original.apply @, arguments

  _authVerified: ->
    for fn in arguments
      do (fn) =>
        original = @[fn]
        @[fn] = (req, res) ->
          return res.redirect 'account/mustVerifyUser' unless req.loggedIn and req.user?.verified
          original.apply @, arguments

  _getSubdomain: (domain, host) ->
    return undefined if @env isnt 'production' and host is 'localhost'
    if host isnt domain and host isnt "www.#{domain}"
      subdomain = host.replace ".#{domain}", ''
    subdomain

  _handleError: (area, req, res, err, errToReturn, json=true) ->
    if typeof errToReturn is 'boolean'
      [errToReturn, json]=[json, errToReturn]
    json = true if errToReturn?
    Err.create area, false, req, err
    if json
      errToReturn = err unless errToReturn?
      res.json 400, errToReturn
    else
      res.send 400
