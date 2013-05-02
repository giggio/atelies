Store   = require '../../../models/store'

describe 'Store', ->
  it 'requires name, city and state to be present', (done) ->
    store = new Store()
    store.validate (val) ->
      expect(val.errors.name.type).toBe 'required'
      expect(val.errors.city.type).toBe 'required'
      expect(val.errors.state.type).toBe 'required'
      done()
  it 'sets the correct slug when name is set', ->
    store = Store.create name:"Minha loja"
    expect(store.slug).toBe 'minha_loja'
