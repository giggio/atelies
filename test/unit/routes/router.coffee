router = require '../../../app/routes/router'
routes = require '../../../app/routes/index'

describe 'Router', ->
  it 'should route admin', ->
    app = get: sinon.spy(), post: sinon.spy(), put: sinon.spy()
    router.route app
    app.get.should.have.been.calledWith '/admin', routes.admin
