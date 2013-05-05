routes      = require '../../../routes'
Store       = require '../../../models/store'
everyauth   = require 'everyauth'

describe 'AdminRoute', ->
  it 'allows access and renders all the stores if signed in and seller', (done) ->
    stores = []
    spyOn(Store, "find").andCallFake (cb) -> cb null, stores
    req = user: isSeller:true
    everyauth.loggedIn = true
    res = createSpyObj 'res', ['render']
    routes.admin req, res
    expect(res.render).toHaveBeenCalledWith 'admin', stores: stores
    done()
  it 'denies access if the user is a seller', ->
    stores = []
    res = createSpyObj 'res', ['redirect']
    everyauth.loggedIn = true
    req = user: isSeller:false
    routes.admin req, res
    expect(res.redirect).toHaveBeenCalledWith 'login'
  it 'denies access if not signed in', ->
    stores = []
    res = createSpyObj 'res', ['redirect']
    everyauth.loggedIn = false
    req = {}
    routes.admin req, res
    expect(res.redirect).toHaveBeenCalledWith 'login'
