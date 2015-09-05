require './support/_specHelper'
Store           = require '../../app/models/store'
Order           = require '../../app/models/order'
Product         = require '../../app/models/product'
StoreHomePage   = require './support/pages/storeHomePage'
request         = require 'request'
Q               = require 'q'
config          = require '../../app/helpers/config'

describe 'store home page', ->
  page = store = null
  before -> page = new StoreHomePage()
  describe 'when store doesnt exist', ->
    describe 'display', ->
      it 'shows not found', ->
        cleanDB()
        .then -> page.visit "store_1"
        .then -> page.notExistentText().should.become 'Loja não existe'
    describe 'status code', ->
      it 'is 404', ->
        Q.nfcall request, "http://localhost:8000/store_1"
        .spread (response, body) -> response.statusCode.should.equal 404
    
  describe 'when store exists and has no products', ->
    before ->
      cleanDB().then ->
        store = generator.store.a()
        Q.ninvoke store, 'save'
      .then -> page.visit "store_1"
    it 'should display no products', -> page.products().then (p) -> p.length.should.equal 0

  describe 'when store exists and has products', ->
    before ->
      cleanDB().then ->
        store = generator.store.a()
        product1 = generator.product.a()
        product2 = generator.product.b()
        Q.all [ Q.ninvoke(store, 'save'), Q.ninvoke(product1, 'save'), Q.ninvoke(product2, 'save') ]
      .then -> page.visit "store_1"
    it 'should display the products', -> page.products().then (p) -> p.length.should.equal 2

  describe.skip 'store at subdomain', ->
    return if config.test.snapci
    before ->
      cleanDB().then ->
        store = generator.store.a()
        product1 = generator.product.a()
        product2 = generator.product.b()
        Q.all [ Q.ninvoke(store, 'save'), Q.ninvoke(product1, 'save'), Q.ninvoke(product2, 'save') ]
      .then -> page.visit "http://store_1.localhost:8000"
    it 'should display the products', -> page.products().then (p) -> p.length.should.equal 2

  describe 'evaluation', ->
    before ->
      cleanDB().then ->
        userEvaluating1 = generator.user.d()
        userEvaluating2 = generator.user.d()
        userEvaluating2.name = "John Smith"
        body1 = "body1"
        body2 = "body2"
        rating1 = 2
        rating2 = 5
        store = generator.store.a()
        product1 = generator.product.a()
        item1 = product: product1, quantity: 1
        Q.all [ Q.ninvoke(store, 'save'), Q.ninvoke(product1, 'save'), Q.ninvoke(userEvaluating1, 'save') , Q.ninvoke(userEvaluating2, 'save') ]
        .then -> Order.create userEvaluating1, store, [ item1 ], 1, 'directSell'
        .then (order) -> Q.ninvoke order, "save"
        .spread (order) -> order.addEvaluation user: userEvaluating1, body: body1, rating: rating1
        .then (result) ->
          Q.ninvoke result.order, "save"
          .then -> Q.ninvoke result.evaluation, "save"
          .then -> Q.ninvoke result.store, "save"
        .then -> Order.create userEvaluating2, store, [ item1 ], 2, 'directSell'
        .then (order) -> Q.ninvoke order, "save"
        .spread (order) -> order.addEvaluation user: userEvaluating2, body: body2, rating: rating2
        .then (result) ->
          Q.ninvoke result.order, "save"
          .then -> Q.ninvoke result.evaluation, "save"
          .then -> Q.ninvoke result.store, "save"
          .then -> page.visit store.slug
    it 'should show the store average evaluation' , ->
      page.evaluation().then (ev) ->
        ev.ratingStars.should.equal 3.5
        ev.ratingDescription.should.equal "(2 avaliações, veja todas)"
