require './support/_specHelper'
Store           = require '../../app/models/store'
Order           = require '../../app/models/order'
Product         = require '../../app/models/product'
StoreHomePage   = require './support/pages/storeHomePage'
request         = require 'request'
Q               = require 'q'

describe 'store home page', ->
  page = store = null
  before ->
    page = new StoreHomePage()
    whenServerLoaded()
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
        store.save()
        page.visit "store_1"
    it 'should display no products', -> page.products().then (p) -> p.length.should.equal 0

  describe 'when store exists and has products', ->
    before ->
      cleanDB().then ->
        store = generator.store.a()
        store.save()
        product1 = generator.product.a()
        product2 = generator.product.b()
        product1.save()
        product2.save()
        page.visit "store_1"
    it 'should display the products', -> page.products().then (p) -> p.length.should.equal 2

  describe 'store at subdomain', ->
    before ->
      cleanDB().then ->
        store = generator.store.a()
        store.save()
        product1 = generator.product.a()
        product2 = generator.product.b()
        product1.save()
        product2.save()
        page.visit "http://store_1.localhost:8000"
    it 'should display the products', -> page.products().then (p) -> p.length.should.equal 2

  describe 'evaluation', ->
    before ->
      cleanDB().then ->
        userEvaluating1 = generator.user.d()
        userEvaluating1.save()
        userEvaluating2 = generator.user.d()
        userEvaluating2.name = "John Smith"
        userEvaluating2.save()
        body1 = "body1"
        body2 = "body2"
        rating1 = 2
        rating2 = 5
        store = generator.store.a()
        store.save()
        product1 = generator.product.a()
        product1.save()
        item1 = product: product1, quantity: 1
        Q.ninvoke Order, "create", userEvaluating1, store, [ item1 ], 1, 'directSell'
        .then (order) ->
          Q.ninvoke order, "save"
          .then ->
            Q.ninvoke order, "addEvaluation", user: userEvaluating1, body: body1, rating: rating1
            .spread (evaluation, updatedStore) ->
              order.save()
              evaluation.save()
              updatedStore.save()
              Q.ninvoke Order, "create", userEvaluating2, store, [ item1 ], 2, 'directSell'
            .then (order) ->
              order.save()
              Q.ninvoke order, "addEvaluation", user: userEvaluating2, body: body2, rating: rating2
            .spread (evaluation, updatedStore) ->
              order.save()
              evaluation.save()
              updatedStore.save()
              page.visit store.slug
    it 'should show the store average evaluation' , ->
      page.evaluation().then (ev) ->
        ev.ratingStars.should.equal 3.5
        ev.ratingDescription.should.equal "(2 avaliações, veja todas)"
