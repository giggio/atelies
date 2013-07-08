Routes          = require '../../../app/routes/admin'
Store           = require '../../../app/models/store'
AccessDenied    = require '../../../app/errors/accessDenied'

describe 'AdminStoreCreateRoute', ->
  routes = null
  before -> routes = new Routes()
  describe 'Access is granted', ->
    store = res = body = user = null
    before ->
      store = pmtGateways: [], save: (cb) -> cb()
      user = isSeller: true
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
      store.name.should.equal body.name
      store.phoneNumber.should.equal body.phoneNumber
      store.city.should.equal body.city
      store.state.should.equal body.state
      store.otherUrl.should.equal body.otherUrl
      store.banner.should.equal body.banner
      store.pmtGateways.pagseguro.email.should.equal 'pagseguro@a.com'
      store.pmtGateways.pagseguro.token.should.equal 'FFFFFDAFADSFIUADSKFLDSJALA9D0CAA'
    it 'added store to the user', ->
      user.createStore.should.have.been.called
    it 'saved the user', ->
      user.save.should.have.been.called

  describe 'Access is denied', ->
    it 'denies access if the user isnt a seller and throws', ->
      req = user: {isSeller:false}, loggedIn: true
      expect( -> routes.adminStoreCreate req, null).to.throw AccessDenied
    it 'throws if not signed in', ->
      req = loggedIn: false
      expect( -> routes.adminStoreCreate req, null).to.throw AccessDenied

