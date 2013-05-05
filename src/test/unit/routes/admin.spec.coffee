routes      = require '../../../routes'
Store       = require '../../../models/store'

describe 'AdminRoute', ->
  it 'allows access and renders all the stores if signed in and seller', ->
    stores = []
    sinon.stub(Store, "find").yields null, stores
    req = user: {isSeller:true}, loggedIn: true
    res = render: sinon.spy()
    routes.admin req, res
    res.render.should.have.been.calledWith 'admin', stores:stores
  it 'denies access if the user isnt a seller and shows a message page', ->
    stores = []
    res = redirect:sinon.spy()
    req = user: {isSeller:false}, loggedIn: true
    routes.admin req, res
    res.redirect.should.have.been.calledWith 'notseller'
  it 'denies access if not signed in', ->
    stores = []
    res = redirect: sinon.spy()
    req = loggedIn: false
    routes.admin req, res
    res.redirect.should.have.been.calledWith 'login'
