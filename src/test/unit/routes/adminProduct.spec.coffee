routes          = require '../../../routes'
Store           = require '../../../models/store'
Product         = require '../../../models/product'
AccessDenied    = require '../../../errors/accessDenied'

describe 'AdminStoreRoute', ->
  describe 'If user owns the store and product', ->
    product = store = req = res = body = user = null
    before ->
      product =
        save: sinon.stub().yields null, product
        storeSlug: 'some_store'
      store = _id: 9876
      sinon.stub(Product, 'findById').yields null, product
      sinon.stub(Store, 'findBySlug').yields null, store
      user =
        isSeller: true
        stores: [9876]
      params = productId: '1234'
      req = loggedIn: true, user: user, params: params, body:
        name: 'Some Product'
        picture: 'http://a.com/a.jpg'
        price: 3.45
        slug: 'whatever'
        storeName: 'Other Store'
        storeSlug: 'other_store'
        tags: 'abc,def'
        description: 'some description'
        height: 3
        width: 4
        depth: 5
        weight: 6
        hasInventory: true
        inventory: 30
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
      res.send.should.have.been.calledWith 200
    it 'product is updated correctly', ->
      product.name.should.equal req.body.name
      product.picture.should.equal req.body.picture
      product.price.should.equal req.body.price
      product.tags.should.be.like req.body.tags.split ','
      product.description.should.equal req.body.description
      product.dimensions.height.should.equal req.body.height
      product.dimensions.width.should.equal req.body.width
      product.dimensions.depth.should.equal req.body.depth
      product.weight.should.equal req.body.weight
      product.hasInventory.should.equal req.body.hasInventory
      product.inventory.should.equal req.body.inventory
    it "does not try to change the product's store", ->
      expect(product.storeName).to.be.undefined
      product.storeSlug.should.equal 'some_store'
    it "does not try to change the product's slug", ->
      expect(product.slug).to.be.undefined
    it 'product should had been saved', ->
      product.save.should.have.been.called

  describe 'Access is denied', ->
    describe "a seller but does not own this product's store", ->
      product = store = req = res = body = user = null
      before ->
        product =
          save: sinon.stub().yields null, product
          storeSlug: 'some_store'
        store = _id: 9876
        sinon.stub(Product, 'findById').yields null, product
        sinon.stub(Store, 'findBySlug').yields null, store
        user =
          isSeller: true
          stores: [6543]
        params = productId: '1234'
        req = loggedIn: true, user: user, params: params, body:
          name: 'Some Product'
        body = req.body
        res = send: sinon.spy()
      it 'denies access and throws', ->
        expect( -> routes.adminProductUpdate req, res).to.throw AccessDenied
    describe 'not a seller', ->
      it 'denies access if the user isnt a seller and throws', ->
        req = user: {isSeller:false}, loggedIn: true
        expect( -> routes.adminProductUpdate req, null).to.throw AccessDenied
      it 'throws if not signed in', ->
        req = loggedIn: false
        expect( -> routes.adminProductUpdate req, null).to.throw AccessDenied
