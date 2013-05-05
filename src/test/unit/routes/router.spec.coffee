router = require '../../../routes/router'
routes = require '../../../routes/index'

describe 'Router', ->
  it 'should route admin', ->
    app = get: sinon.spy(), post: sinon.spy()
    router.route app
    app.get.should.have.been.calledWith '/admin', routes.admin
