require '../support/_specHelper'
Product     = require '../../../app/models/product'
Store       = require '../../../app/models/store'
User        = require '../../../app/models/user'
Postman     = require '../../../app/models/postman'

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
      shippingHeight: 7
      shippingWidth: 8
      shippingDepth: 9
      shippingWeight: 10
      hasInventory: true
      inventory: 30
    product = new Product()
    store = new Store()
    store.addCategories = ->
    store.updateProduct product, simpleProduct
    product.name.should.equal simpleProduct.name
    product.price.should.equal simpleProduct.price
    print product.tags
    product.tags.should.be.like simpleProduct.tags.split ','
    product.description.should.equal simpleProduct.description
    product.dimensions.height.should.equal simpleProduct.height
    product.dimensions.width.should.equal simpleProduct.width
    product.dimensions.depth.should.equal simpleProduct.depth
    product.weight.should.equal simpleProduct.weight
    product.shipping.dimensions.height.should.equal simpleProduct.shippingHeight
    product.shipping.dimensions.width.should.equal simpleProduct.shippingWidth
    product.shipping.dimensions.depth.should.equal simpleProduct.shippingDepth
    product.shipping.weight.should.equal simpleProduct.shippingWeight
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
    simpleProduct.tags.should.equal product.tags.join ','
    simpleProduct.description.should.equal product.description
    simpleProduct.height.should.equal product.dimensions.height
    simpleProduct.width.should.equal product.dimensions.width
    simpleProduct.depth.should.equal product.dimensions.depth
    simpleProduct.weight.should.equal product.weight
    simpleProduct.shippingApplies.should.equal product.shipping.applies
    simpleProduct.shippingHeight.should.equal product.shipping.dimensions.height
    simpleProduct.shippingWidth.should.equal product.shipping.dimensions.width
    simpleProduct.shippingDepth.should.equal product.shipping.dimensions.depth
    simpleProduct.shippingWeight.should.equal product.shipping.weight
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
  it 'has shipping info if shipping applies', ->
    product = generator.product.a()
    product.shipping.applies = true
    product.hasShippingInfo().should.be.true
    product.shipping.applies = false
    product.hasShippingInfo().should.be.false
  it 'does not have shipping info if missing or wrong shipping info', ->
    product = generator.product.a()
    product.shipping.applies = true
    product.shipping.dimensions.height = 1
    product.hasShippingInfo().should.be.false
  describe 'has comments', ->
    user = product = store = userCommenting = body = comment = null
    before (done) ->
      Postman.sentMails.length = 0
      product = generator.product.a()
      userCommenting = generator.user.a()
      title = "some title"
      body = "some comment"
      store = generator.store.a()
      user = generator.store.b()
      sinon.stub(Store, "findBySlug").yields null, store
      sinon.stub(User, "findAdminsFor").yields null, [user]
      product.addComment {user: userCommenting, body: body}, (err, commentCreated) ->
        return done err if err?
        comment = commentCreated
        done()
    after ->
      Store.findBySlug.restore()
      User.findAdminsFor.restore()
    it 'added the comment to the product', ->
      comment.user.should.equal userCommenting._id
      comment.userName.should.equal userCommenting.name
      comment.userEmail.should.equal userCommenting.email
      comment.body.should.equal body
      comment.date.should.equalDate new Date()
    it 'sent email', ->
      Postman.sentMails.length.should.equal 1
      mail = Postman.sentMails[0]
      mail.to.should.equal "'#{user.name}' <#{user.email}>"
      mail.subject.should.equal "Ateliês: O produto #{product.name} da loja #{store.name} recebeu um comentário"
