Product         = require '../models/product'
User            = require '../models/user'
Store           = require '../models/store'
_               = require 'underscore'
AccessDenied    = require '../errors/accessDenied'
values          = require '../helpers/values'
RouteFunctions  = require './routeFunctions'

module.exports = class AdminRoutes
  constructor: (@env) ->
    @_authSiteAdmin 'siteAdmin', 'storesForAuthorization', 'updateStoreFlyerAuthorization'
  _.extend @::, RouteFunctions::

  handleError: @::_handleError.partial 'siteAdmin'

  siteAdmin: (req, res) ->
    req.user.toSimpleUser (user) ->
      res.render 'siteAdmin/siteAdmin', user: user

  storesForAuthorization: (req, res) ->
    isFlyerAuthorized = switch req.params.isFlyerAuthorized
      when undefined then undefined
      when 'true' then true
      else false
    Store.findSimpleByFlyerAuthorization isFlyerAuthorized, (err, stores) =>
      return @handleError req, res, err if err?
      res.json stores

  updateStoreFlyerAuthorization: (req, res) ->
    Store.findById req.params._id, (err, store) ->
      return @handleError req, res, err if err?
      isFlyerAuthorized = req.params.isFlyerAuthorized is 'true'
      store.isFlyerAuthorized = isFlyerAuthorized
      store.save()
      store.sendMailAfterFlyerAuthorization req.user, (err) ->
        return @handleError req, res, err if err?
        res.json 200
