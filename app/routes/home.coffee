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
Q               = require 'q'

module.exports = class HomeRoutes
  constructor: (@env) ->
  _.extend @::, RouteFunctions::

  handleError: @::_handleError.partial 'admin'

  logError: @::_logError.partial 'admin'
  
  index: (domain) ->
    route = (req, res) =>
      subdomain = @_getSubdomain domain, req.headers.host.toLowerCase()
      if subdomain?
        req.params.storeSlug = subdomain
        return @storeWithDomain req, res
      Product.findRandom 12, (err, products) =>
        return @handleError req, res, err, false if err?
        viewModelProducts = _.map products, (p) -> p.toSimplerProduct()
        Store.findRandomForHome 12, (err, stores) =>
          return @handleError req, res, err, false if err?
          viewModelStores = _.map stores, (s) -> s.toSimpler()
          res.render "home/index", products: viewModelProducts, stores: viewModelStores
    route

  blank: (req, res) -> res.render 'home/blank'

  about: (req, res) -> res.render 'home/about'

  terms: (req, res) -> res.render 'home/terms'

  faq: (req, res) -> res.render 'home/faq'

  technology: (req, res) -> res.render 'home/technology'

  iWantToBuy: (req, res) -> res.render 'home/iWantToBuy'

  iWantToSell: (req, res) -> res.render 'home/iWantToSell'

  contribute: (req, res) -> res.render 'home/contribute'

  donating: (req, res) -> res.render 'home/donating'
  
  search: (req, res) ->
    Q.all [
      Store.searchByName req.params.searchTerm
      Product.searchByName req.params.searchTerm
      Product.searchByTag req.params.searchTerm
      Product.searchByCategory req.params.searchTerm
    ]
    .catch (err) => @handleError req, res, err
    .spread (stores, products, productsTag, productsCat) ->
      toSimple = (ps) -> _.map ps, (p) -> p.toSimpleProduct()
      viewModelProducts = _.union toSimple(products), toSimple(productsTag), toSimple productsCat
      res.json products: viewModelProducts, stores: stores

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
