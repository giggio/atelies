Product         = require '../models/product'
User            = require '../models/user'
Store           = require '../models/store'
Order           = require '../models/order'
_               = require 'underscore'
everyauth       = require 'everyauth'
AccessDenied    = require '../errors/accessDenied'
values          = require '../helpers/values'
correios        = require 'correios'
RouteFunctions  = require './routeFunctions'
ProductUploader = require '../models/productUploader'
StoreUploader   = require '../models/storeUploader'

module.exports = class AdminRoutes
  constructor: (@env) ->
    @_authSiteAdmin 'siteAdmin'
  _.extend @::, RouteFunctions::

  handleError: @::_handleError.partial 'siteAdmin'

  siteAdmin: (req, res) ->
    req.user.toSimpleUser (user) ->
      res.render 'siteAdmin', user: user
