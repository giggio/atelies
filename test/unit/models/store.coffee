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
  it 'adds name keywords when created', ->
    store = new Store name:"Minha Loja"
    store.nameKeywords.should.be.like ['minha', 'loja']
  it 'adds name keywords when name is set', ->
    store = new Store()
    store.name = "Minha Loja"
    store.nameKeywords.should.be.like ['minha', 'loja']
  it 'name keywords is empty without a name', ->
    store = new Store()
    store.name = ""
    store.nameKeywords.should.be.like []
  it 'name keywords is null without a name', ->
    store = new Store()
    store.name = null
    store.nameKeywords.should.be.like []
