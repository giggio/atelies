Routes          = require '../../../app/routes/admin'
Store           = require '../../../app/models/store'
Product         = require '../../../app/models/product'
AccessDenied    = require '../../../app/errors/accessDenied'
Q               = require 'q'

describe 'AdminProductUpdateRoute', ->
  routes = null
  before -> routes = new Routes()
  describe 'If user owns the store and product', ->
    product = store = req = res = body = user = null
    before ->
      product =
        save: sinon.stub().yields null, product
        storeSlug: 'some_store'
        toSimpleProduct: ->
      store =
        _id: 9876
        slug: product.storeSlug
        updateProduct: sinon.stub().returns product
        save: sinon.stub().yields()
      sinon.stub(Product, 'findById').yields null, product
      sinon.stub(Store, 'findBySlug').returns Q.fcall -> store
      user =
        isSeller: true
        stores: [9876]
        hasStore: -> true
      params = productId: '1234', storeSlug: store.slug
      req = loggedIn: true, user: user, params: params, body: {}
      body = req.body
      res = send: sinon.spy()
      routes.adminProductUpdate req, res
    after ->
      Product.findById.restore()
      Store.findBySlug.restore()
    it 'looked for correct product', ->
      Product.findById.should.have.been.calledWith req.params.productId
    it 'looked for correct store', ->
      Store.findBySlug.should.have.been.calledWith product.storeSlug
    it 'access allowed and return code is correct', ->
      res.send.should.have.been.calledWith 204
    it 'product is updated correctly', ->
      store.updateProduct.should.have.been.calledWith product, req.body
    it "does not try to change the product's store", ->
      expect(product.storeName).to.be.undefined
      product.storeSlug.should.equal 'some_store'
    it "does not try to change the product's slug", ->
      expect(product.slug).to.be.undefined
    it 'product should had been saved', ->
      product.save.should.have.been.called
    it 'saved the store', ->
      store.save.should.have.been.called

  describe 'Access is denied', ->
    it "a seller but does not own this product's store denies access and throws", sinon.test ->
      product =
        save: sinon.stub().yields null, product
        storeSlug: 'some_store'
      store = _id: 9876
      sinon.stub(Product, 'findById').yields null, product
      sinon.stub(Store, 'findBySlug').returns Q.fcall -> store
      user =
        isSeller: true
        stores: [6543]
        hasStore: -> false
      params = productId: '1234'
      req = loggedIn: true, user: user, params: params, body:
        name: 'Some Product'
      body = req.body
      res = json: sinon.spy()
      sinon.stub routes, '_logError'
      routes.adminProductUpdate req, res
      .then -> res.json.should.have.been.calledWith 400
    describe 'not a seller', ->
      it 'denies access if the user isnt a seller and throws', ->
        req = user: {isSeller:false}, loggedIn: true
        expect( -> routes.adminProductUpdate req, null).to.throw AccessDenied
      it 'throws if not signed in', ->
        req = loggedIn: false
        expect( -> routes.adminProductUpdate req, null).to.throw AccessDenied
