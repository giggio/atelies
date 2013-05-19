routes          = require '../../../app/routes'
Store           = require '../../../app/models/store'
AccessDenied    = require '../../../app/errors/accessDenied'

describe 'AdminStoreRoute', ->
  describe 'Access is granted', ->
    store = res = body = user = null
    before ->
      store = save: (cb) -> cb()
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
      body = req.body
      res = json: sinon.spy()
      routes.adminStore req, res
    it 'access allowed and return code is correct', ->
      res.json.should.have.been.calledWith 201, store
    it 'store is created correctly', ->
      store.name.should.equal body.name
      store.phoneNumber.should.equal body.phoneNumber
      store.city.should.equal body.city
      store.state.should.equal body.state
      store.otherUrl.should.equal body.otherUrl
      store.banner.should.equal body.banner
    it 'added store to the user', ->
      user.createStore.should.have.been.called
    it 'saved the user', ->
      user.save.should.have.been.called

  describe 'Access is denied', ->
    it 'denies access if the user isnt a seller and throws', ->
      req = user: {isSeller:false}, loggedIn: true
      expect( -> routes.adminStore req, null).to.throw AccessDenied
    it 'throws if not signed in', ->
      req = loggedIn: false
      expect( -> routes.adminStore req, null).to.throw AccessDenied

