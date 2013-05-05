router = require '../../../routes/router'
routes = require '../../../routes/index'

describe 'Router', ->
  it 'should route admin', ->
    app = createSpyObj 'app', ['get', 'post']
    router.route app
    expect(app.get).toHaveBeenCalledWith '/admin', routes.admin
