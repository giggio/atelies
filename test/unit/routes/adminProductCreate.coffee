SandboxedModule = require 'sandboxed-module'
Store           = require '../../../app/models/store'
Product         = require '../../../app/models/product'
AccessDenied    = require '../../../app/errors/accessDenied'
Q               = require 'q'

describe 'AdminProductCreateRoute', ->
  describe 'If user owns the store and product', sinon.test ->
    simpleProduct = toSimpleProductStub = ProductStub = saveStub = product = store = req = res = body = user = createProductSpy = null
    before ->
      simpleProduct = {}
      saveStub = sinon.stub().yields null, product
      toSimpleProductStub = sinon.stub().returns simpleProduct
      class ProductStub
        @created: false
        constructor: ->
          ProductStub.created = true
          product = @
        save: saveStub
        storeSlug: 'some_store'
        toSimpleProduct: toSimpleProductStub
        isNew: true
      createProductSpy = sinon.stub().returns new ProductStub()
      store =
        _id: 9876
        slug: 'some_store'
        name: 'Some Store'
        createProduct: createProductSpy
        addCategories: (categories, cb) -> cb()
        save: sinon.stub().yields()
        calculateProductCount: sinon.spy()
      sinon.stub(Store, 'findBySlug').returns Q.fcall -> store
      user =
        isSeller: true
        stores: [9876]
        hasStore: -> true
      params = storeSlug: store.slug
      req = loggedIn: true, user: user, params: params, body:
        storeSlug: store.slug
      body = req.body
      res = json: sinon.spy()
      Routes = SandboxedModule.require '../../../app/routes/admin',
        requires:
          '../models/product': ProductStub
          '../models/store': Store
        singleOnly: true
      routes = new Routes()
      routes.adminProductCreate req, res
    after ->
      Store.findBySlug.restore()
    it 'created a product', -> ProductStub.created.should.be.true
    it 'saved the store', -> store.save.should.have.been.called
    it 'looked for correct store', -> Store.findBySlug.should.have.been.calledWith store.slug
    it 'access allowed and return code is correct', -> res.json.should.have.been.calledWith 201, simpleProduct
    it 'product is updated correctly', -> createProductSpy.should.have.been.calledWith req.body
    it 'product should had been saved', -> saveStub.should.have.been.called
    it 'calculated product count', -> store.calculateProductCount.should.have.been.called

  describe 'Access is denied', ->
    routes = null
    before ->
      Routes = require '../../../app/routes/admin'
      routes = new Routes()
    it "a seller but does not own this product's store denies access and throws", sinon.test ->
      @stub(Store, 'findBySlug').returns Q.fcall ->
      user =
        isSeller: true
        hasStore: -> false
      req = loggedIn: true, user: user, body: {}, params: {}
      res = json: sinon.spy()
      sinon.stub routes, '_logError'
      routes.adminProductCreate req, res
      .then -> res.json.should.have.been.calledWith 400
    it 'denies access if the user isnt a seller and throws', ->
      req = user: {isSeller:false}, loggedIn: true
      expect( -> routes.adminProductCreate req, null).to.throw AccessDenied
    it 'throws if not signed in', ->
      req = loggedIn: false
      expect( -> routes.adminProductCreate req, null).to.throw AccessDenied
