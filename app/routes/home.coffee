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

module.exports = class HomeRoutes
  constructor: (@env) ->
  _.extend @::, RouteFunctions::

  handleError: @::_handleError.partial 'admin'

  logError: @::_logError.partial 'admin'
  
  index: (domain) ->
    route = (req, res) =>
      subdomain = @_getSubdomain domain, req.host.toLowerCase()
      if subdomain?
        req.params.storeSlug = subdomain
        return @storeWithDomain req, res
      Product.findRandom 12, (err, products) =>
        return @handleError req, res, err, false if err?
        viewModelProducts = _.map products, (p) -> p.toSimplerProduct()
        Store.findRandomForHome 12, (err, stores) =>
          return @handleError req, res, err, false if err?
          viewModelStores = _.map stores, (s) -> s.toSimpler()
          res.render "index", products: viewModelProducts, stores: viewModelStores
    route

  blank: (req, res) -> res.render 'blank'

  about: (req, res) -> res.render 'about'

  terms: (req, res) -> res.render 'terms'

  faq: (req, res) -> res.render 'faq'

  technology: (req, res) -> res.render 'technology'

  iWantToBuy: (req, res) -> res.render 'iWantToBuy'

  iWantToSell: (req, res) -> res.render 'iWantToSell'

  contribute: (req, res) -> res.render 'contribute'

  donating: (req, res) -> res.render 'donating'
  
  storesSearch: (req, res) ->
    Store.searchByName req.params.searchTerm, (err, stores) =>
      return @handleError req, res, err if err?
      res.json stores
  
  productsSearch: (req, res) ->
    Product.searchByName req.params.searchTerm, (err, products) =>
      return @handleError req, res, err if err?
      viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
      res.json viewModelProducts
