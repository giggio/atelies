require '../support/_specHelper'
Order       = require '../../../app/models/order'
User        = require '../../../app/models/user'
Store       = require '../../../app/models/store'
Product     = require '../../../app/models/product'
Postman     = require '../../../app/models/postman'
Q           = require 'q'
_           = require 'underscore'

describe.only 'Order', ->
  order = store = user = p1 = p2 = shippingCost = null
  before ->
    user = new User()
    deliveryAddress =
      street: 'a'
      street2: 'b'
      city: 'c'
      state: 'SP'
      zip: '12345-678'
    user.deliveryAddress = deliveryAddress
    user.name = "Jose Silva"
    user.email = "a@a.com"
    store = new Store()
    store.name = "O Lojista"
    store.email = "a@store.com"
    p1 = new Product price: 10, name: 'p1name'
    p2 = new Product price: 20, name: 'p2name'
    item1 = product: p1, quantity: 1, name: p1.name
    item2 = product: p2, quantity: 2, name: p2.name
    items = [ item1, item2 ]
    shippingCost = 1
    Q.nfcall Order.create, user, store, items, shippingCost, 'directSell'
    .then (o) -> order = o

  describe 'creating', ->
    it 'assigned customer', ->
      order.customer.should.equal user._id
    it 'assigned store', ->
      order.store.should.equal store._id
    it 'assigned prices', ->
      order.shippingCost.should.equal shippingCost
      order.totalProductsPrice.should.equal 50
      order.totalSaleAmount.should.equal 51
    it 'has correct date', ->
      (new Date() - order.orderDate).should.be.below 2000
    it 'has delivery address', ->
      order.deliveryAddress.toJSON().should.be.like user.deliveryAddress.toJSON()
    it 'has items', ->
      items = order.items
      items.length.should.equal 2
      item1 = items[0]
      item1.price.should.equal p1.price
      item1.quantity.should.equal 1
      item1.product.should.equal p1._id
      item1.totalPrice.should.equal p1.price
      item2 = items[1]
      item2.price.should.equal p2.price
      item2.quantity.should.equal 2
      item2.product.should.equal p2._id
      item2.totalPrice.should.equal p2.price * 2
    it 'created a direct sell order', ->
      order.paymentType.should.equal 'directSell'

  describe 'sending client and seller e-mail after purchase', ->
    before ->
      order.populate = (path, cb) ->
        orderStub = order.toObject()
        orderStub.store = store
        orderStub.customer = user
        cb null, orderStub
      Postman.sentMails.length = 0
      Q.ninvoke order, 'sendMailAfterPurchase'
    it 'shoud have sent the e-mails', ->
      Postman.sentMails.length.should.equal 2
