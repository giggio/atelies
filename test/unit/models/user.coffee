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
