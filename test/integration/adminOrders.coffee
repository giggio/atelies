require './support/_specHelper'
Order               = require '../../app/models/order'
AdminOrdersPage     = require './support/pages/adminOrdersPage'
Q                   = require 'q'

describe 'Admin orders page', ->
  page = store = product1 = product2 = user =  userSeller = order1 = order2 = null
  before ->
    page = new AdminOrdersPage()
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
      order2 = generator.order.b()
      order2.customer = user
      order2.deliveryAddress = user.deliveryAddress
      order2.store = store
      order2.items[0].product = product1
      userSeller = generator.user.c()
      userSeller.stores.push store
      Q.all [Q.ninvoke(store, 'save'), Q.ninvoke(user, 'save'), Q.ninvoke(product1, 'save'), Q.ninvoke(product2, 'save'), Q.ninvoke(order1, 'save'), Q.ninvoke(order2, 'save'), Q.ninvoke(userSeller, 'save') ]

  describe 'with two orders', ->
    before ->
      page.loginFor userSeller._id
      .then page.visit
    it 'shows orders', ->
      page.orders().then (orders) ->
        orders.length.should.equal 2
        o1 = orders[0]
        o2 = orders[1]
        o1.orderDate.should.equal '01/01/2013'
        o1.storeName.should.equal store.name
        o1.numberOfItems.should.equal order1.items.length
        o1.totalSaleAmount.should.equal 'R$ 12,10'
        o1.orderLink.should.equal "http://localhost:8000/admin/orders/#{o1._id.toString()}"
        o1.status.should.equal 'Pedido realizado'
        o2.orderDate.should.equal '05/01/2013'
        o2.storeName.should.equal store.name
        o2.storeLink.should.equal "http://localhost:8000/#{store.slug}"
        o2.numberOfItems.should.equal order2.items.length
        o2.totalSaleAmount.should.equal 'R$ 23,20'
        o2.orderLink.should.equal "http://localhost:8000/admin/orders/#{o2._id.toString()}"
        o2.status.should.equal 'Pedido realizado'
