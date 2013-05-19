Store   = require '../../../app/models/store'

describe 'Store', ->
  it 'requires name, city and state to be present', (done) ->
    store = new Store()
    store.validate (val) ->
      expect(val.errors.name.type).to.equal 'required'
      expect(val.errors.city.type).to.equal 'required'
      expect(val.errors.state.type).to.equal 'required'
      done()
  it 'sets the correct slug when store is created', ->
    store = new Store name:"Minha loja"
    expect(store.slug).to.equal 'minha_loja'
  it 'sets the correct slug when name is set', ->
    store = new Store()
    store.name = "Minha loja"
    expect(store.slug).to.equal 'minha_loja'
