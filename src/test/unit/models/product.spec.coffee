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
  it 'updated from simple product', ->
    simpleProduct =
      name: 'Some Product'
      picture: 'http://a.com/a.jpg'
      price: 3.45
      slug: 'whatever'
      storeName: 'Other Store'
      storeSlug: 'other_store'
      tags: 'abc,def'
      description: 'some description'
      height: 3
      width: 4
      depth: 5
      weight: 6
      hasInventory: true
      inventory: 30
    product = new Product()
    product.updateFromSimpleProduct simpleProduct
    product.name.should.equal simpleProduct.name
    product.picture.should.equal simpleProduct.picture
    product.price.should.equal simpleProduct.price
    product.tags.should.be.like simpleProduct.tags.split ','
    product.description.should.equal simpleProduct.description
    product.dimensions.height.should.equal simpleProduct.height
    product.dimensions.width.should.equal simpleProduct.width
    product.dimensions.depth.should.equal simpleProduct.depth
    product.weight.should.equal simpleProduct.weight
    product.hasInventory.should.equal simpleProduct.hasInventory
    product.inventory.should.equal simpleProduct.inventory
