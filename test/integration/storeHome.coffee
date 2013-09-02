require './support/_specHelper'
Store           = require '../../app/models/store'
Product         = require '../../app/models/product'
StoreHomePage   = require './support/pages/storeHomePage'
request         = require 'request'

describe 'store home page', ->
  page = store = null
  before (done) ->
    page = new StoreHomePage()
    whenServerLoaded done
  describe 'when store doesnt exist', ->
    describe 'display', ->
      it 'shows not found', (done) ->
        cleanDB (error) ->
          return done error if error
          page.visit "store_1", ->
            page.notExistentText (t) ->
              t.should.equal 'Loja não existe'
              done()
    describe 'status code', ->
      it 'is 404', (done) ->
        request "http://localhost:8000/store_1", (error, response, body) ->
          done error if error
          response.statusCode.should.equal 404
          done()
    
  describe 'when store exists and has no products', ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        store = generator.store.a()
        store.save()
        page.visit "store_1", done
    it 'should display no products', (done) ->
      page.products (p) ->
        p.length.should.equal 0
        done()

  describe 'when store exists and has products', ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        store = generator.store.a()
        store.save()
        product1 = generator.product.a()
        product2 = generator.product.b()
        product1.save()
        product2.save()
        page.visit "store_1", done
    it 'should display the products', (done) ->
      page.products (p) ->
        p.length.should.equal 2
        done()

  describe 'store at subdomain', ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        store = generator.store.a()
        store.save()
        product1 = generator.product.a()
        product2 = generator.product.b()
        product1.save()
        product2.save()
        page.visit "http://store_1.localhost.com:8000", done
    it 'should display the products', (done) ->
      page.products (p) ->
        p.length.should.equal 2
        done()

  describe 'evaluation', ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        userEvaluating1 = generator.user.a()
        userEvaluating2 = generator.user.b()
        body1 = "body1"
        body2 = "body2"
        rating1 = 2
        rating2 = 5
        store = generator.store.a()
        store.addEvaluation {user: userEvaluating1, body: body1, rating: rating1}, ->
          store.addEvaluation {user: userEvaluating2, body: body2, rating: rating2}, ->
            store.save()
            product1 = generator.product.a()
            product2 = generator.product.b()
            product1.save()
            product2.save()
            page.visit "store_1", done
    it 'should show the store average evaluation' , (done) ->
      page.evaluation (ev) ->
        ev.ratingStars.should.equal 3.5
        ev.ratingDescription.should.equal "(2 avaliações, veja todas)"
        done()
