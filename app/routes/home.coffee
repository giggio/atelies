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

class Routes
  constructor: (@env) ->
  
  index: (domain) ->
    route = (req, res) =>
      subdomain = @_getSubdomain domain, req.host.toLowerCase()
      if subdomain?
        req.params.storeSlug = subdomain
        return @storeWithDomain req, res
      Product.findRandom 12, (err, products) =>
        return res.send 400 if err?
        viewModelProducts = _.map products, (p) -> p.toSimplerProduct()
        Store.findRandomForHome 12, (err, stores) ->
          return res.send 400 if err?
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
    Store.searchByName req.params.searchTerm, (err, stores) ->
      return res.send 400 if err?
      res.json stores
  
  productsSearch: (req, res) ->
    Product.searchByName req.params.searchTerm, (err, products) ->
      return res.send 400 if err?
      viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
      res.json viewModelProducts

  isHealthy: (req, res) ->
    res.send 200

_.extend Routes::, RouteFunctions::

module.exports = Routes
