routes      = require '../../../routes'
Store       = require '../../../models/store'

describe 'AdminRoute', ->
  it 'renders all the stores', (done) ->
    stores = []
    spyOn(Store, "find").andCallFake (cb) -> cb null, stores
    res = createSpyObj 'res', ['render']
    routes.admin null, res
    expect(res.render).toHaveBeenCalledWith 'admin', stores: stores
    done()
