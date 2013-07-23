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

class Routes
  constructor: (@env) ->
    @_auth 'admin'
    @_authVerified 'adminStoreCreate'
    @_authSeller 'adminStoreCreate', 'adminStoreUpdate', 'adminProductUpdate', 'adminProductDelete', 'adminProductCreate', 'adminStoreUpdateSetAutoCalculateShippingOff', 'adminStoreUpdateSetAutoCalculateShippingOn', 'adminStoreUpdateSetPagseguroOff', 'adminStoreUpdateSetPagseguroOn', 'storeProduct', 'storeProducts', 'orders', 'order'
  
  admin: (req, res) ->
    return res.redirect 'notseller' unless req.user.isSeller
    req.user.populate 'stores', (err, user) ->
      res.render 'admin', stores: _.map(user.stores, (s) -> s.toSimple()), user: req.user.toSimpleUser()

  adminStoreCreate: (req, res) ->
    body = req.body
    name = body.name
    Store.nameExists name, (err, itExists) ->
      return res.json 409, error: user: "Loja já existe com esse nome." if itExists
      store = req.user.createStore()
      store.updateFromSimple body
      store.autoCalculateShipping = if body.autoCalculateShipping? then !!body.autoCalculateShipping else false
      if body.pagseguro is on then store.setPagseguro email: body.pagseguroEmail, token: body.pagseguroToken
      uploader = new StoreUploader store
      imageFields = homePageImage: Store.homePageImageDimension, banner: null, flyer: Store.flyerDimension
      uploader.upload req.files, imageFields, (err, fileUrls) =>
        if err?
          return res.json 422, err if err.smallerThan?
          return res.json 400, error: uploadError: err
        for field, fileUrl of fileUrls
          store[field] = fileUrl if fileUrl?
        store.save (err) ->
          return res.json 400, error: saveError: err if err?
          req.user.save (err) ->
            if err?
              store.remove()
              return res.json 400, error: userSaveError: err
            res.json 201, store
  
  adminStoreUpdate: (req, res) ->
    Store.findById req.params.storeId, (err, store) ->
      dealWith err
      throw new AccessDenied() unless req.user.hasStore store
      checkIfNameCanBelongToStore = (cb) ->
        if store.name isnt req.body.name
          Store.nameExists req.body.name, (err, itExists) ->
            return res.json 409, error: user: "Loja já existe com esse nome." if itExists
            cb()
        else
          cb()
      checkIfNameCanBelongToStore =>
        store.updateFromSimple req.body
        uploader = new StoreUploader store
        imageFields = homePageImage: Store.homePageImageDimension, banner: null, flyer: Store.flyerDimension
        uploader.upload req.files, imageFields, (err, fileUrls) =>
          if err?
            return res.json 422, err if err.smallerThan?
            return res.json 400, error: uploadError: err
          for field, fileUrl of fileUrls
            store[field] = fileUrl if fileUrl?
          store.save (err) ->
            return res.json 400 if err?
            res.send 200, store
  adminStoreUpdateSetAutoCalculateShippingOff: (req, res) -> @_adminStoreUpdateSetAutoCalculateShipping req, res, off
  adminStoreUpdateSetAutoCalculateShippingOn: (req, res) -> @_adminStoreUpdateSetAutoCalculateShipping req, res, on
  _adminStoreUpdateSetAutoCalculateShipping: (req, res, autoCalculateShipping) ->
    Store.findById req.params.storeId, (err, store) ->
      dealWith err
      throw new AccessDenied() unless req.user.hasStore store
      store.setAutoCalculateShipping autoCalculateShipping, (set) ->
        if set
          store.save (err) ->
            return res.json 400 if err?
            res.send 204
        else
          res.send 409
  adminStoreUpdateSetPagseguroOff: (req, res) -> @_adminStoreUpdateSetPagseguro req, res, off
  adminStoreUpdateSetPagseguroOn: (req, res) -> @_adminStoreUpdateSetPagseguro req, res, email: req.body.email, token: req.body.token
  _adminStoreUpdateSetPagseguro: (req, res, set) ->
    Store.findById req.params.storeId, (err, store) ->
      dealWith err
      throw new AccessDenied() unless req.user.hasStore store
      store.setPagseguro set
      store.save (err) ->
        return res.json 400 if err?
        res.send 204

  adminProductUpdate: (req, res) ->
    Store.findBySlug req.params.storeSlug, (err, store) =>
      return res.json 400, err if err?
      throw new AccessDenied() unless req.user.hasStore store
      Product.findById req.params.productId, (err, product) =>
        return res.json 400, err if err?
        return res.json 400 if product.storeSlug isnt store.slug
        @_productUpdate req, res, product
  
  adminProductCreate: (req, res) ->
    Store.findBySlug req.params.storeSlug, (err, store) =>
      return res.json 400, err if err?
      throw new AccessDenied() unless req.user.hasStore store
      product = store.createProduct()
      @_productUpdate req, res, product

  _productUpdate: (req, res, product) ->
    product.updateFromSimpleProduct req.body
    uploader = new ProductUploader()
    uploader.upload product, req.files?.picture, (err, fileUrl) =>
      return res.json 422, err if err?.smallerThan?
      return res.json 400, err if err?
      product.picture = fileUrl if fileUrl?
      isNew = product.isNew
      product.save (err) =>
        return res.json 400, err if err?
        if isNew
          res.json 201, product.toSimpleProduct()
        else
          res.send 204
  
  adminProductDelete: (req, res) ->
    Product.findById req.params.productId, (err, product) ->
      dealWith err
      Store.findBySlug product.storeSlug, (err, store) ->
        dealWith err
        throw new AccessDenied() unless req.user.hasStore store
        product.remove (err) ->
          res.send 204

  storeProducts: (req, res) ->
    Product.findByStoreSlug req.params.storeSlug, (err, products) ->
      dealWith err
      viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
      res.json viewModelProducts
  
  storeProduct: (req, res) ->
    Product.findById req.params.productId, (err, product) ->
      dealWith err
      if product?
        res.json product.toSimpleProduct()
      else
        res.send 404

  orders: (req, res) ->
    user = req.user
    Order.getSimpleByStores user.stores, (err, orders) ->
      return res.json 400, err if err?
      res.json orders

  order: (req, res) ->
    Order.findSimpleWithItemsBySellerAndId req.user, req.params._id, (err, order) ->
      return res.json 400, err if err?
      res.json order
  
_.extend Routes::, RouteFunctions::

module.exports = Routes
