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
Q               = require 'q'

module.exports = class AdminRoutes
  constructor: (@env) ->
    @_auth 'admin'
    @_authVerified 'adminStoreCreate'
    @_authSeller 'adminStoreCreate', 'adminStoreUpdate', 'adminProductUpdate', 'adminProductDelete', 'adminProductCreate', 'adminStoreUpdateSetPagseguroOff', 'adminStoreUpdateSetPagseguroOn', 'adminStoreUpdateSetPaypalOff', 'adminStoreUpdateSetPaypalOn', 'storeProduct', 'storeProducts', 'orders', 'order', 'updateOrderStatus'
  _.extend @::, RouteFunctions::

  handleError: @::_handleError.partial 'admin'
  
  admin: (req, res) ->
    return res.redirect 'notseller' unless req.user.isSeller
    Q.ninvoke req.user, 'populate', 'stores'
    .then (user) -> [user.toSimpleUser(), user.stores.map (s) -> s.toSimple()]
    .spread (user, stores) -> res.render 'admin/admin', stores: stores, user: user
    .catch (err) => return @handleError req, res, err, false

  adminStoreCreate: (req, res) ->
    body = req.body
    name = body.name
    @_convertBodyToBool req.body, 'pagseguro', 'paypal'
    Store.nameExists name
    .then (itExists) =>
      return res.json 409, error: user: "Loja já existe com esse nome." if itExists
      store = req.user.createStore()
      store.updateFromSimple body
      store.name = body.name
      if body.pagseguro is on then store.setPagseguro email: body.pagseguroEmail, token: body.pagseguroToken
      if body.paypal is on then store.setPaypal clientId: body.paypalClientId, secret: body.paypalSecret
      uploader = new StoreUploader store
      imageFields = banner: null, flyer: Store.flyerDimension
      uploader.upload req.files, imageFields
      .catch (err) =>
        return res.json 422, err if err.smallerThan?
        @handleError req, res, err, error: uploadError: err
      .then (fileUrls) =>
        for field, fileUrl of fileUrls
          store[field] = fileUrl if fileUrl?
        Q.ninvoke(store, 'save').catch (err) => @handleError req, res, err, error: saveError: err
      .then ->
        Q.ninvoke(req.user, 'save').catch (err) =>
          store.remove()
          @handleError req, res, err, userSaveError: err
      .then -> res.json 201, store
  
  adminStoreUpdate: (req, res) ->
    Q.ninvoke Store, 'findById', req.params.storeId
    .then (store) ->
      throw new AccessDenied() unless req.user.hasStore store
      Q.fcall ->
        if store.name isnt req.body.name
          Store.nameExists req.body.name
          .then (itExists) ->
            if itExists then throw new Error "ExistentStore"
            store.updateName req.body.name
        else
          store
    .then (store) ->
      store.updateFromSimple req.body
      uploader = new StoreUploader store
      imageFields = banner: null, flyer: Store.flyerDimension
      uploader.upload req.files, imageFields
      .catch (err) ->
        if err.smallerThan? then throw err
        throw error: uploadError: err
      .then (fileUrls) ->
        for field, fileUrl of fileUrls
          store[field] = fileUrl if fileUrl?
        Q.ninvoke store, 'save'
      .then -> res.send 200, store
    .catch (err) =>
      if err.smallerThan? then return res.json 422, err
      if err.message is "ExistentStore" then return res.json 409, error: user: "Loja já existe com esse nome."
      @handleError req, res, err

  adminStoreUpdateSetPagseguroOff: (req, res) -> @_adminStoreUpdateSetPagseguro req, res, off
  adminStoreUpdateSetPagseguroOn: (req, res) -> @_adminStoreUpdateSetPagseguro req, res, email: req.body.email, token: req.body.token
  _adminStoreUpdateSetPagseguro: (req, res, set) ->
    Q.ninvoke Store, 'findById', req.params.storeId
    .then (store) ->
      throw new AccessDenied() unless req.user.hasStore store
      store.setPagseguro set
      Q.ninvoke store, 'save'
    .then -> res.send 204
    .catch (err) => @handleError req, res, err
  adminStoreUpdateSetPaypalOff: (req, res) -> @_adminStoreUpdateSetPaypal req, res, off
  adminStoreUpdateSetPaypalOn: (req, res) -> @_adminStoreUpdateSetPaypal req, res, clientId: req.body.clientId, secret: req.body.secret
  _adminStoreUpdateSetPaypal: (req, res, set) ->
    Q.ninvoke Store, 'findById', req.params.storeId
    .then (store) ->
      throw new AccessDenied() unless req.user.hasStore store
      store.setPaypal set
      Q.ninvoke store, 'save'
    .then -> res.send 204
    .catch (err) => @handleError req, res, err

  adminProductUpdate: (req, res) ->
    Store.findBySlug req.params.storeSlug
    .then (store) =>
      throw new AccessDenied() unless req.user.hasStore store
      Q.ninvoke Product, 'findById', req.params.productId
      .then (product) =>
        throw new Error() if product.storeSlug isnt store.slug
        @_convertBodyToBool req.body, 'shippingApplies', 'shippingCharge', 'hasInventory'
        @_convertBodyToEmptyToUndefined req.body, 'name', 'price', 'description', 'weight', 'hasInventory', 'inventory', 'height', 'width', 'depth'
        store.updateProduct product, req.body
      .then (product) => @_productUpdate req, res, product, store
    .catch (err) =>
      return res.json 409, err if err?.nameExists?
      @handleError req, res, err
  
  adminProductCreate: (req, res) ->
    Store.findBySlug req.params.storeSlug
    .then (store) =>
      throw new AccessDenied() unless req.user.hasStore store
      @_convertBodyToBool req.body, 'shippingApplies', 'shippingCharge', 'hasInventory'
      @_convertBodyToEmptyToUndefined req.body, 'name', 'price', 'description', 'weight', 'hasInventory', 'inventory', 'height', 'width', 'depth'
      [store, store.createProduct req.body]
    .spread (store, product) => @_productUpdate req, res, product, store
    .catch (err) =>
      return res.json 409, err if err.nameExists?
      @handleError req, res, err

  _productUpdate: (req, res, product, store) ->
    uploader = new ProductUploader()
    uploader.upload product, req.files?.picture
    .then (fileUrl) ->
      product.picture = fileUrl if fileUrl?
      Q.ninvoke product, 'save'
    .then -> Q.ninvoke store, 'save'
    .then -> if product.isNew then res.json 201, product.toSimpleProduct() else res.send 204
    .catch (err) =>
      return res.json 422, err if err.smallerThan?
      @handleError req, res, err
  
  adminProductDelete: (req, res) ->
    Q.ninvoke Product, 'findById', req.params.productId
    .then (product) -> [product, Store.findBySlug product.storeSlug]
    .spread (product, store) ->
      throw new AccessDenied() unless req.user.hasStore store
      Q.ninvoke product, 'remove'
    .then -> res.send 204
    .catch (err) => @handleError req, res, err

  storeProducts: (req, res) ->
    Product.findByStoreSlug req.params.storeSlug
    .then (products) ->
      viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
      res.json viewModelProducts
    .catch (err) => @handleError req, res, err
  
  storeProduct: (req, res) ->
    Q.ninvoke Product, 'findById', req.params.productId
    .then (product) ->
      if product?
        res.json product.toSimpleProduct()
      else
        res.send 404
    .catch (err) => @handleError req, res, err

  orders: (req, res) ->
    user = req.user
    Order.getSimpleByStores user.stores
    .then (orders) -> res.json orders
    .catch (err) => @handleError req, res, err

  order: (req, res) ->
    Order.findSimpleWithItemsBySellerAndId req.user, req.params._id
    .then (order) -> res.json order
    .catch (err) => @handleError req, res, err

  storeCategories: (req, res) ->
    Q.ninvoke Store, 'findById', req.params.storeId
    .then (store) -> res.json store.categories
    .catch (err) => @handleError req, res, err

  updateOrderStatus: (req, res) ->
    Q.ninvoke Order, 'findById', req.params._id
    .then (order) ->
      throw new AccessDenied() unless req.user.hasStore order.store
      order.state = req.params.newOrderState
      Q.ninvoke order, 'save'
    .spread (order) -> order.sendMailAfterStateChange()
    .then -> res.send 204
    .catch (err) => @handleError req, res, err
