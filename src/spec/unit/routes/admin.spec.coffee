routes      = require '../../../routes'
Store       = require '../../../models/store'

describe 'AdminRoute', ->
  it 'allows access and renders all the stores if signed in and seller', (done) ->
    stores = []
    spyOn(Store, "find").andCallFake (cb) -> cb null, stores
    req = user: {isSeller:true}, loggedIn: true
    res = createSpyObj 'res', ['render']
    routes.admin req, res
    expect(res.render).toHaveBeenCalledWith 'admin', stores: stores
    done()
  it 'denies access if the user isnt a seller and shows a message page', ->
    stores = []
    res = createSpyObj 'res', ['redirect']
    req = user: {isSeller:false}, loggedIn: true
    routes.admin req, res
    expect(res.redirect).toHaveBeenCalledWith 'notseller'
  it 'denies access if not signed in', ->
    stores = []
    res = createSpyObj 'res', ['redirect']
    req = loggedIn: false
    routes.admin req, res
    expect(res.redirect).toHaveBeenCalledWith 'login'
