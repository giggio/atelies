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
    @_auth 'admin'
    @_authVerified 'adminStoreCreate'
    @_authSeller 'adminStoreCreate', 'adminStoreUpdate', 'adminProductUpdate', 'adminProductDelete', 'adminProductCreate', 'adminStoreUpdateSetPagseguroOff', 'adminStoreUpdateSetPagseguroOn', 'storeProduct', 'storeProducts', 'orders', 'order'
  _.extend @::, RouteFunctions::

  handleError: @::_handleError.partial 'admin'
  
  admin: (req, res) ->
    return res.redirect 'notseller' unless req.user.isSeller
    req.user.populate 'stores', (err, user) =>
      return @handleError req, res, err, false if err?
      stores = _.map user.stores, (s) -> s.toSimple()
      req.user.toSimpleUser (user) ->
        res.render 'admin/admin', stores: stores, user: user

  adminStoreCreate: (req, res) ->
    body = req.body
    name = body.name
    @_convertBodyToBool req.body, 'pagseguro'
    Store.nameExists name, (err, itExists) =>
      return res.json 409, error: user: "Loja já existe com esse nome." if itExists
      store = req.user.createStore()
      store.updateFromSimple body
      store.name = body.name
      if body.pagseguro is on then store.setPagseguro email: body.pagseguroEmail, token: body.pagseguroToken
      uploader = new StoreUploader store
      imageFields = banner: null, flyer: Store.flyerDimension
      uploader.upload req.files, imageFields, (err, fileUrls) =>
        if err?
          return res.json 422, err if err.smallerThan?
          return @handleError req, res, err, error: uploadError: err
        for field, fileUrl of fileUrls
          store[field] = fileUrl if fileUrl?
        store.save (err) ->
          return @handleError req, res, err, error: saveError: err if err?
          req.user.save (err) =>
            if err?
              store.remove()
              return @handleError req, res, err, userSaveError: err
            res.json 201, store
  
  adminStoreUpdate: (req, res) ->
    Store.findById req.params.storeId, (err, store) =>
      return @handleError req, res, err if err?
      throw new AccessDenied() unless req.user.hasStore store
      checkIfNameCanBelongToStore = (cb) =>
        if store.name isnt req.body.name
          Store.nameExists req.body.name, (err, itExists) =>
            return res.json 409, error: user: "Loja já existe com esse nome." if itExists
            store.updateName req.body.name, (err) =>
              return @handleError req, res, err if err?
              cb()
        else
          cb()
      checkIfNameCanBelongToStore =>
        store.updateFromSimple req.body
        uploader = new StoreUploader store
        imageFields = banner: null, flyer: Store.flyerDimension
        uploader.upload req.files, imageFields, (err, fileUrls) =>
          if err?
            return res.json 422, err if err.smallerThan?
            return @handleError req, res, err, error: uploadError: err
          for field, fileUrl of fileUrls
            store[field] = fileUrl if fileUrl?
          store.save (err) =>
            return @handleError req, res, err if err?
            res.send 200, store
  adminStoreUpdateSetPagseguroOff: (req, res) -> @_adminStoreUpdateSetPagseguro req, res, off
  adminStoreUpdateSetPagseguroOn: (req, res) -> @_adminStoreUpdateSetPagseguro req, res, email: req.body.email, token: req.body.token
  _adminStoreUpdateSetPagseguro: (req, res, set) ->
    Store.findById req.params.storeId, (err, store) =>
      return @handleError req, res, err if err?
      throw new AccessDenied() unless req.user.hasStore store
      store.setPagseguro set
      store.save (err) =>
        return @handleError req, res, err if err?
        res.send 204

  adminProductUpdate: (req, res) ->
    Store.findBySlug req.params.storeSlug, (err, store) =>
      return @handleError req, res, err if err?
      throw new AccessDenied() unless req.user.hasStore store
      Product.findById req.params.productId, (err, product) =>
        return @handleError req, res, err if err?
        return @handleError req, res, new Error() if product.storeSlug isnt store.slug
        @_convertBodyToBool req.body, 'shippingApplies', 'shippingCharge', 'hasInventory'
        @_convertBodyToEmptyToUndefined req.body, 'name', 'price', 'description', 'weight', 'hasInventory', 'inventory', 'height', 'width', 'depth'
        store.updateProduct product, req.body, (err) =>
          return res.json 409, err if err?.nameExists?
          return @handleError req, res, err if err?
          @_productUpdate req, res, product, store
  
  adminProductCreate: (req, res) ->
    Store.findBySlug req.params.storeSlug, (err, store) =>
      return @handleError req, res, err if err?
      throw new AccessDenied() unless req.user.hasStore store
      @_convertBodyToBool req.body, 'shippingApplies', 'shippingCharge', 'hasInventory'
      @_convertBodyToEmptyToUndefined req.body, 'name', 'price', 'description', 'weight', 'hasInventory', 'inventory', 'height', 'width', 'depth'
      store.createProduct req.body, (err, product) =>
        return res.json 409, err if err?.nameExists?
        return @handleError req, res, err if err?
        @_productUpdate req, res, product, store

  _productUpdate: (req, res, product, store) ->
    uploader = new ProductUploader()
    uploader.upload product, req.files?.picture, (err, fileUrl) =>
      return res.json 422, err if err?.smallerThan?
      return @handleError req, res, err if err?
      product.picture = fileUrl if fileUrl?
      isNew = product.isNew
      product.save (err) =>
        return @handleError req, res, err if err?
        store.save (err) =>
          return @handleError req, res, err if err?
          if isNew
            res.json 201, product.toSimpleProduct()
          else
            res.send 204
  
  adminProductDelete: (req, res) ->
    Product.findById req.params.productId, (err, product) =>
      return @handleError req, res, err if err?
      Store.findBySlug product.storeSlug, (err, store) =>
        return @handleError req, res, err if err?
        throw new AccessDenied() unless req.user.hasStore store
        product.remove (err) ->
          res.send 204

  storeProducts: (req, res) ->
    Product.findByStoreSlug req.params.storeSlug, (err, products) =>
      return @handleError req, res, err if err?
      viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
      res.json viewModelProducts
  
  storeProduct: (req, res) ->
    Product.findById req.params.productId, (err, product) =>
      return @handleError req, res, err if err?
      if product?
        res.json product.toSimpleProduct()
      else
        res.send 404

  orders: (req, res) ->
    user = req.user
    Order.getSimpleByStores user.stores, (err, orders) =>
      return @handleError req, res, err if err?
      res.json orders

  order: (req, res) ->
    Order.findSimpleWithItemsBySellerAndId req.user, req.params._id, (err, order) =>
      return @handleError req, res, err if err?
      res.json order

  storeCategories: (req, res) ->
    Store.findById req.params.storeId, (err, store) =>
      return @handleError req, res, err if err?
      res.json store.categories
