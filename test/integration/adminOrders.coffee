require './support/_specHelper'
Order               = require '../../app/models/order'
AdminOrdersPage     = require './support/pages/adminOrdersPage'

describe 'Admin orders page', ->
  page = store = product1 = product2 = user =  userSeller = order1 = order2 = null
  before (done) =>
    page = new AdminOrdersPage()
    cleanDB (error) ->
      return done error if error
      store = generator.store.a()
      store.save()
      user = generator.user.a()
      user.deliveryAddress = generator.user.d().deliveryAddress
      user.save()
      product1 = generator.product.a()
      product1.save()
      product2 = generator.product.b()
      product2.save()
      order1 = generator.order.a()
      order1.customer = user
      order1.deliveryAddress = user.deliveryAddress
      order1.store = store
      order1.items[0].product = product1
      order1.save()
      order2 = generator.order.b()
      order2.customer = user
      order2.deliveryAddress = user.deliveryAddress
      order2.store = store
      order2.items[0].product = product1
      order2.save()
      userSeller = generator.user.c()
      userSeller.stores.push store
      userSeller.save()
      whenServerLoaded done

  describe 'with two orders', ->
    before (done) =>
      page.loginFor userSeller._id, ->
        page.visit done
    it 'shows orders', (done) ->
      page.orders (orders) ->
        orders.length.should.equal 2
        o1 = orders[0]
        o2 = orders[1]
        o1.orderDate.should.equal '01/01/2013'
        o1.storeName.should.equal store.name
        o1.numberOfItems.should.equal order1.items.length
        o1.totalSaleAmount.should.equal 'R$ 12,10'
        o1.orderLink.should.equal "http://localhost:8000/admin#orders/#{o1._id.toString()}"
        o2.orderDate.should.equal '05/01/2013'
        o2.storeName.should.equal store.name
        o2.storeLink.should.equal "http://localhost:8000/#{store.slug}"
        o2.numberOfItems.should.equal order2.items.length
        o2.totalSaleAmount.should.equal 'R$ 23,20'
        o2.orderLink.should.equal "http://localhost:8000/admin#orders/#{o2._id.toString()}"
        done()
