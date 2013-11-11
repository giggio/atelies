_               = require 'underscore'
AccessDenied    = require '../errors/accessDenied'
values          = require '../helpers/values'
config          = require '../helpers/config'
Err             = require '../models/error'
url             = require 'url'

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

  _authSiteAdmin: ->
    for fn in arguments
      do (fn) =>
        original = @[fn]
        @[fn] = (req, res) ->
          unless req.loggedIn and req.user?.isAdmin
            return res.render 'accessDenied', (err, html) =>
              res.send 403, html
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
    @_logError area, req, err
    if json
      errToReturn = err unless errToReturn?
      res.json 400, errToReturn
    else
      res.send 400
  _logError: (area, req, err) ->
    Err.createServer area, req, err
  _convertToBool: (val) ->
    val? and (val is true or val is 'true')
  _convertBodyToBool: (body, fields...) ->
    body[field] = @_convertToBool body[field] for field in fields
  _convertEmptyToUndefined: (val) ->
    if val? and val isnt '' then val else undefined
  _convertBodyToEmptyToUndefined: (body, fields...) ->
    body[field] = @_convertEmptyToUndefined body[field] for field in fields
  redirectAddingDash: (req, res) ->
    reqUrl = url.parse req.originalUrl
    return res.redirect 301, "#{reqUrl.pathname}/?#{reqUrl.query}" unless _.isEmpty req.query
    res.redirect 301, "#{reqUrl.pathname}/"
