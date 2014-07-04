require './support/_specHelper'
Order                   = require '../../app/models/order'
Store                   = require '../../app/models/store'
StoreEvaluation         = require '../../app/models/storeEvaluation'
AccountOrderDetailPage  = require './support/pages/accountOrderDetailPage'
Postman                 = require '../../app/models/postman'
Q                       = require 'q'

describe 'Account order detail page', ->
  page = store = product1 = product2 = user = order1 = userSeller = null
  before ->
    page = new AccountOrderDetailPage()
    whenServerLoaded()
  setup = ->
    cleanDB()
    .then ->
      store = generator.store.a()
      Q.ninvoke store, 'save'
    .then ->
      userSeller = generator.user.c()
      userSeller.stores.push store
      Q.ninvoke userSeller, 'save'
    .then ->
      product1 = generator.product.a()
      Q.ninvoke product1, 'save'
    .then ->
      product2 = generator.product.b()
      Q.ninvoke product2, 'save'
    .then ->
      user = generator.user.d()
      Q.ninvoke user, 'save'
    .then ->
      items = [
        { product: product1, quantity: 1 }
        { product: product2, quantity: 2 }
      ]
      shippingCost = 1
      Order.create user, store, items, shippingCost, 'directSell'
    .then (order) ->
      order1 = order
      order.orderDate = new Date(2013,0,1)
      Q.ninvoke order1, 'save'

  describe 'show order with two products', ->
    before ->
      setup()
      .then -> page.loginFor user._id
      .then -> page.visit order1._id
    it 'shows order', ->
      page.order().then (order) ->
        order._id.should.equal order._id.toString()
        order.orderDate.should.equal '01/01/2013'
        order.storeName.should.equal store.name
        order.storeUrl.should.equal "http://localhost:8000/#{store.slug}"
        order.numberOfItems.should.equal order1.items.length
        order.shippingCost.should.equal 'R$ 1,00'
        order.totalProductsPrice.should.equal 'R$ 55,50'
        order.totalSaleAmount.should.equal 'R$ 56,50'
        order.deliveryAddress.street.should.equal user.deliveryAddress.street
        order.deliveryAddress.street2.should.equal user.deliveryAddress.street2
        order.deliveryAddress.city.should.equal user.deliveryAddress.city
        order.deliveryAddress.state.should.equal user.deliveryAddress.state
        order.deliveryAddress.zip.should.equal user.deliveryAddress.zip
        order.items.length.should.equal 2
        i1 = order.items[0]
        i2 = order.items[1]
        i1._id.should.equal product1._id.toString()
        i1.name.should.equal product1.name
        i1.price.should.equal 'R$ 11,10'
        i1.totalPrice.should.equal 'R$ 11,10'
        i1.picture.should.equal product1.picture
        i1.quantity.should.equal 1
        i1.url.should.equal "http://localhost:8000/#{product1.url()}"
        i2._id.should.equal product2._id.toString()
        i2.name.should.equal product2.name
        i2.price.should.equal 'R$ 22,20'
        i2.totalPrice.should.equal 'R$ 44,40'
        i2.picture.should.equal product2.picture
        i2.quantity.should.equal 2
        i2.url.should.equal "http://localhost:8000/#{product2.url()}"
    it 'shows pending evaluation', -> page.newEvaluationVisible().should.eventually.be.true

  describe 'evaluation order and store', ->
    evaluationBody = rating = null
    before ->
      setup()
      .then ->
        Postman.sentMails.length = 0
        evaluationBody = "body1"
        rating = 4
        page.loginFor user._id
      .then -> page.visit order1._id
      .then -> page.evaluateOrderWith body: evaluationBody, rating: rating
    it 'should record the evaluation on the store', test ->
      Q.ninvoke Store, "findById", store._id
      .then (st) ->
        st.numberOfEvaluations.should.equal 1
        st.evaluationAvgRating.should.equal 4
    it 'should have stored the evaluation and set it on the order', test ->
      Q.ninvoke StoreEvaluation, "findOne", order: order1._id
      .then (ev) ->
        ev.body.should.equal evaluationBody
        ev.rating.should.equal rating
        ev.date.should.equalDate new Date()
        ev.store.toString().should.equal order1.store.toString()
        ev.order.toString().should.equal order1._id.toString()
        ev.user.toString().should.equal user._id.toString()
        Q.ninvoke Order, "findById", order1._id
        .then (o) -> o.evaluation.toString().should.equal ev._id.toString()
    it 'should make the evaluation field disappear', test -> page.newEvaluationVisible().should.eventually.be.false
    it 'should show existing evaluation', test -> page.existingEvaluation().should.become rating
    it 'should send an e-mail message to the store admins', test ->
      Postman.sentMails.length.should.equal 1
      mail = Postman.sentMails[0]
      mail.to.should.equal "#{userSeller.name} <#{userSeller.email}>"
      mail.subject.should.equal "Ateliês: A loja #{store.name} recebeu uma avaliação"
    it 'does not show pending evaluation anymore when visited again and shows existing evaluation', test ->
      page.reload().then ->
        Q.all [
          page.newEvaluationVisible().should.eventually.be.false
          page.existingEvaluation().should.become rating
        ]
