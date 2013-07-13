User    = require '../../../app/models/user'
Store   = require '../../../app/models/store'

describe 'User', ->
  it 'creates stores', ->
    user = new User isSeller: true
    store = user.createStore()
    store.isNotNull
    user.stores.length.should.equal 1
  it 'cant create store if not seller', ->
    user = new User isSeller: false
    user.createStore.throws
  it 'after wrong login user increases login error', (done) ->
    user = generator.user.a()
    user.save = sinon.stub().yields()
    user.verifyPassword 'a', ->
      user.loginError.should.equal 1
      user.save.should.have.beenCalled
      done()
  it 'after wrong login and successful login login errors goes back to zero', (done) ->
    user = generator.user.a()
    user.save = sinon.stub().yields()
    user.verifyPassword 'a', ->
      user.verifyPassword user.password, ->
        user.loginError.should.equal 0
        user.save.should.have.been.calledTwice
        done()
  it 'is considered careful login after 3 wrong login tries', ->
    user = generator.user.a()
    user.loginError = 3
    user.carefulLogin().should.equal.true
