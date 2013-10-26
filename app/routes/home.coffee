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
Err             = require '../models/error'

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

  errorCreate: (req, res) ->
    err = req.body
    err.user = req.user
    Err.createClient err
    res.send 200

  staticFile: (file) ->
    path = require 'path'
    publicDir = path.join __dirname, '..', '..', "public"
    (req, res) ->
      filePath = path.join publicDir, file
      res.sendfile filePath

  sitemap: ->
    sm = require 'sitemap'
    map =
      hostname: 'https://www.atelies.com.br/',
      cacheTime: 12 * 60 * 60 * 1000 # twice a day, in miliseconds
      urls: [
         { url: '',  changefreq: 'always', priority: 0.6 }
         { url: 'faq', changefreq: 'monthly', priority: 0.1 }
         { url: "about",  changefreq: 'monthly', priority: 0.1 }
         { url: "terms", changefreq: 'monthly', priority: 0.1 }
         { url: "faq", changefreq: 'monthly', priority: 0.1 }
         { url: "technology", changefreq: 'monthly', priority: 0.1 }
         { url: "iWantToBuy", changefreq: 'monthly', priority: 0.1 }
         { url: "iWantToSell", changefreq: 'monthly', priority: 0.1 }
         { url: "contribute", changefreq: 'monthly', priority: 0.1 }
         { url: "donating", changefreq: 'monthly', priority: 0.1 }
      ]
    Store.find().select('slug').exec (err, stores) ->
      unless err?
        map.urls.push { url: store.slug, changefreq: 'weekly', priority: 0.7 } for store in stores
    Product.find().select('slug storeSlug').exec (err, products) ->
      unless err?
        map.urls.push { url: product.url(), changefreq: 'weekly', priority: 0.7 } for product in products
    sitemap = sm.createSitemap map
    (req, res) ->
      sitemap.toXML (xml) ->
        res.header 'Content-Type', 'application/xml'
        res.send xml
