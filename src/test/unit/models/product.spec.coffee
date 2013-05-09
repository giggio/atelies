Product     = require '../../../models/product'

describe 'Product', ->
  xit 'requires name to be present', (done) ->
    store = new Product()
    store.validate (val) ->
      expect(val.errors.name.type).to.equal 'required'
      done()
  it 'sets the correct slug when store is created', ->
    product = new Product name:"Meu produto"
    expect(product.slug).to.equal 'meu_produto'
  it 'sets the correct slug when name is set', ->
    product = new Product()
    product.name = "Meu Produto"
    expect(product.slug).to.equal 'meu_produto'
