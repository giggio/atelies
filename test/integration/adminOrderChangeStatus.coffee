require './support/_specHelper'
Order               = require '../../app/models/order'
AdminOrderPage      = require './support/pages/adminOrderPage'
Q                   = require 'q'
Postman             = require '../../app/models/postman'

describe 'Admin order page with status', ->
  page = store = product1 = product2 = user =  userSeller = order1 = null
  before ->
    page = new AdminOrderPage()
    cleanDB().then ->
      store = generator.store.a()
      user = generator.user.a()
      user.deliveryAddress = generator.user.d().deliveryAddress
      product1 = generator.product.a()
      product2 = generator.product.b()
      order1 = generator.order.a()
      order1.customer = user
      order1.deliveryAddress = user.deliveryAddress
      order1.store = store
      order1.items[0].product = product1
      userSeller = generator.user.c()
      userSeller.stores.push store
      Q.all [Q.ninvoke(store, 'save'), Q.ninvoke(user, 'save'), Q.ninvoke(product1, 'save'), Q.ninvoke(product2, 'save'), Q.ninvoke(order1, 'save'), Q.ninvoke(userSeller, 'save') ]

  describe 'order just created', ->
    before ->
      page.loginFor userSeller._id
      .then -> page.visit order1._id
    it 'shows correct status', -> page.orderState().should.become 'Pedido realizado'
  describe 'changing order status from ordered to delivered', ->
    before ->
      Postman.sentMails.length = 0
      page.loginFor userSeller._id
      .then -> page.visit order1._id
      .then -> page.changeStateTo 'delivered'
    it 'shows correct status', -> page.orderState().should.become 'Entregue'
    it 'updated the database', ->
      Q.ninvoke Order, 'findById', order1._id
      .then (o) -> o.state.should.equal 'delivered'
    it 'sent an email to the seller', ->
      Postman.sentMails.length.should.equal 1
      mail = Postman.sentMails[0]
      mail.to.should.equal "#{user.name} <#{user.email}>"
      mail.subject.should.equal "Ateliês: Seu pedido na loja #{store.name} foi alterado"
