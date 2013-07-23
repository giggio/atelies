SandboxedModule = require 'sandboxed-module'
Store           = require '../../../app/models/store'
AccessDenied    = require '../../../app/errors/accessDenied'

describe 'AdminStoreCreateRoute', ->
  routes = null
  describe 'Access is granted', ->
    store = res = body = user = req = null
    before ->
      class StoreStub
        @nameExists: (name, cb) ->
          @nameLookedAfter = name
          setImmediate -> cb null, false
      Routes = SandboxedModule.require '../../../app/routes/admin',
        requires:
          '../models/store': StoreStub
      routes = new Routes()
      store = pmtGateways: [], save: sinon.stub().yields(), updateFromSimple: sinon.spy(), setPagseguro: sinon.spy()
      user = isSeller: true, verified: true
      user.createStore = -> store
      user.save = (cb) -> cb null, user
      sinon.spy user, 'createStore'
      sinon.spy user, 'save'
      req = loggedIn: true, user: user, body:
        name: 'a'
        phoneNumber: 'b'
        city: 'c'
        state: 'd'
        otherUrl: 'e'
        banner: 'f'
        pagseguro: true
        pagseguroEmail: 'pagseguro@a.com'
        pagseguroToken: 'FFFFFDAFADSFIUADSKFLDSJALA9D0CAA'
      body = req.body
      res = json: sinon.spy()
      routes.adminStoreCreate req, res
    it 'access allowed and return code is correct', ->
      res.json.should.have.been.calledWith 201, store
    it 'store is created correctly', ->
      store.updateFromSimple.should.have.been.calledWith req.body
    it 'saved pagseguro', ->
      store.setPagseguro.should.have.been.calledWith email: 'pagseguro@a.com', token: 'FFFFFDAFADSFIUADSKFLDSJALA9D0CAA'
    it 'added store to the user', ->
      user.createStore.should.have.been.called
    it 'saved the user', ->
      user.save.should.have.been.called

  describe 'Access is denied', ->
    Routes = require '../../../app/routes/admin'
    before -> routes = new Routes()
    it 'denies access if the user isnt a seller and throws', ->
      req = user: {isSeller:false}, loggedIn: true
      expect( -> routes.adminStoreCreate req, null).to.throw AccessDenied
    it 'throws if not signed in', ->
      req = loggedIn: false
      expect( -> routes.adminStoreCreate req, null).to.throw AccessDenied

  describe 'Redirected if not verified', ->
    it 'denies access if the user isnt a seller and throws', ->
      req = user: {isSeller:true, verified:false}, loggedIn: true
      res = redirect: sinon.spy()
      routes.adminStoreCreate req, res
      res.redirect.should.have.been.calledWith 'account/mustVerifyUser'

  describe "Can't create store with the same name", ->
    StoreStub = store = res = body = user = req = null
    before ->
      class StoreStub
        @nameExists: (name, cb) ->
          @nameLookedAfter = name
          setImmediate -> cb null, true
      Routes = SandboxedModule.require '../../../app/routes/admin',
        requires:
          '../models/store': StoreStub
      routes = new Routes()
      store = pmtGateways: [], save: sinon.stub().yields(), updateFromSimple: sinon.spy()
      user = isSeller: true, verified: true
      user.createStore = -> store
      user.save = (cb) -> cb null, user
      sinon.spy user, 'createStore'
      sinon.spy user, 'save'
      req = loggedIn: true, user: user, body:
        name: 'Some Name'
        phoneNumber: 'b'
        city: 'c'
        state: 'd'
        otherUrl: 'e'
        banner: 'f'
        pagseguro: true
        pagseguroEmail: 'pagseguro@a.com'
        pagseguroToken: 'FFFFFDAFADSFIUADSKFLDSJALA9D0CAA'
      body = req.body
      res = json: sinon.spy()
      routes.adminStoreCreate req, res
    it 'access allowed and return code is correct', ->
      res.json.should.have.been.calledWith 409, error: user: "Loja já existe com esse nome."
    it 'searched store name', ->
      StoreStub.nameLookedAfter.should.equal 'Some Name'
    it 'store isnt created', ->
      store.updateFromSimple.should.not.have.been.called
    it 'added store to the user', ->
      user.createStore.should.not.have.been.called
    it 'saved the user', ->
      user.save.should.not.have.been.called
