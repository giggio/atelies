require '../support/_specHelper'
Product     = require '../../../app/models/product'

describe 'Product', ->
  it 'requires name to be present', (done) ->
    product = new Product()
    product.validate (val) ->
      val.errors.name.type.should.equal 'required'
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
  it 'should produce the correct url', ->
    product = new Product(name: 'name 1', slug: 'name_1', picture: 'http://lorempixel.com/150/150/cats', price: 11.1, storeName: 'store 1', storeSlug: 'store_1')
    expect(product.url()).to.equal "#{product.storeSlug}##{product.slug}"
  it 'produces a simple product', ->
    product = generator.product.a()
    simpleProduct = product.toSimpleProduct()
    simpleProduct.name.should.equal product.name
    simpleProduct.picture.should.equal product.picture
    simpleProduct.price.should.equal product.price
    simpleProduct.slug.should.equal product.slug
    simpleProduct.storeName.should.equal product.storeName
    simpleProduct.storeSlug.should.equal product.storeSlug
    simpleProduct.tags.should.equal product.tags.join ', '
    simpleProduct.description.should.equal product.description
    simpleProduct.height.should.equal product.dimensions.height
    simpleProduct.width.should.equal product.dimensions.width
    simpleProduct.depth.should.equal product.dimensions.depth
    simpleProduct.weight.should.equal product.weight
    simpleProduct.hasInventory.should.equal product.hasInventory
    simpleProduct.inventory.should.equal product.inventory
  it 'produces a simple product with empty tags', ->
    product = generator.product.a()
    product.tags = []
    simpleProduct = product.toSimpleProduct()
    simpleProduct.tags.should.equal ''
  it 'produces a simple product with undefined tags', ->
    product = generator.product.a()
    product.tags = undefined
    simpleProduct = product.toSimpleProduct()
    simpleProduct.tags.should.equal ''
  it 'adds name keywords when created', ->
    product = new Product name:"Meu produto"
    product.nameKeywords.should.be.like ['meu', 'produto']
  it 'adds name keywords when name is set', ->
    product = new Product()
    product.name = "Meu Produto"
    product.nameKeywords.should.be.like ['meu', 'produto']
  it 'name keywords is empty without a name', ->
    product = new Product()
    product.name = ""
    product.nameKeywords.should.be.like []
  it 'name keywords is null without a name', ->
    product = new Product()
    product.name = null
    product.nameKeywords.should.be.like []
