Routes          = require '../../../app/routes/admin'
Store           = require '../../../app/models/store'
AccessDenied    = require '../../../app/errors/accessDenied'

describe 'AdminStoreUpdateRoute', ->
  routes = null
  before -> routes = new Routes()
  describe 'If user owns the store', ->
    exampleStore = store = req = res = body = user = null
    before ->
      exampleStore = generator.store.a().toJSON()
      delete exampleStore.nameKeywords
      delete exampleStore.slug
      exampleStore._id = '9876'
      store =
        _id: '9876'
        name: exampleStore.name
        zip: '01234-567'
        pmtGateways:
          pagseguro:
            email: 'pagseguro@a.com'
            token: 'FFFFFDAFADSFIUADSKFLDSJALA9D0CAA'
        save: sinon.stub().yields()
        updateFromSimple: sinon.spy()
      sinon.stub(Store, 'findById').yields null, store
      user =
        isSeller: true
        stores: ['9876']
        hasStore: -> true
      params = storeId: '9876'
      req = loggedIn: true, user: user, params: params, body: exampleStore
      res = send: sinon.spy()
      routes.adminStoreUpdate req, res
    after ->
      Store.findById.restore()
    it 'looked for correct store', ->
      Store.findById.should.have.been.calledWith store._id
    it 'access allowed and return code is correct', ->
      res.send.should.have.been.calledWith 200
    it 'store is updated correctly', ->
      store.updateFromSimple.should.have.been.calledWith req.body
    it 'store should had been saved', ->
      store.save.should.have.been.called

  describe 'Access is denied', ->
    describe "a seller but does not own this store", ->
      store = req = res = body = user = null
      before ->
        store =
          _id: '9876'
          save: sinon.spy()
        sinon.stub(Store, 'findById').yields null, store
        user =
          isSeller: true
          stores: ['6543']
          hasStore: -> false
        params = storeId: '9876'
        req = loggedIn: true, user: user, params: params, body:
          name: 'Some Store'
        body = req.body
        res = send: sinon.spy()
      after ->
        Store.findById.restore()
      it 'denies access and throws', ->
        expect( -> routes.adminStoreUpdate req, res).to.throw AccessDenied
    describe 'not a seller', ->
      it 'denies access if the user isnt a seller and throws', ->
        req = user: {isSeller:false}, loggedIn: true
        expect( -> routes.adminStoreUpdate req, null).to.throw AccessDenied
      it 'throws if not signed in', ->
        req = loggedIn: false
        expect( -> routes.adminStoreUpdate req, null).to.throw AccessDenied

  describe "Can't update store with the same name", ->
    exampleStore = store = req = res = body = user = null
    before ->
      exampleStore = generator.store.a().toJSON()
      delete exampleStore.nameKeywords
      delete exampleStore.slug
      exampleStore._id = '9876'
      store =
        _id: '9876'
        name: exampleStore.name + 'aaa'
        zip: '01234-567'
        pmtGateways:
          pagseguro:
            email: 'pagseguro@a.com'
            token: 'FFFFFDAFADSFIUADSKFLDSJALA9D0CAA'
        save: sinon.stub().yields()
        updateFromSimple: sinon.spy()
      sinon.stub(Store, 'findById').yields null, store
      sinon.stub(Store, 'nameExists').yields null, true
      user =
        isSeller: true
        stores: ['9876']
        hasStore: -> true
      params = storeId: '9876'
      req = loggedIn: true, user: user, params: params, body: exampleStore
      res = json: sinon.spy()
      routes.adminStoreUpdate req, res
    after ->
      Store.findById.restore()
      Store.nameExists.restore()
    it 'looked for correct store', ->
      Store.findById.should.have.been.calledWith store._id
    it 'looked for correct name', ->
      Store.nameExists.should.have.been.calledWith exampleStore.name
    it 'returned conflict 409', ->
      res.json.should.have.been.calledWith 409
    it 'store is updated correctly', ->
      store.updateFromSimple.should.not.have.been.called
    it 'store should had been saved', ->
      store.save.should.not.have.been.called
