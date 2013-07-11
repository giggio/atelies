require './support/_specHelper'
Store           = require '../../app/models/store'
Product         = require '../../app/models/product'
StoreHomePage   = require './support/pages/storeHomePage'
request         = require 'request'

describe 'store home page', ->
  page = store = null
  before -> page = new StoreHomePage()
  describe 'when store doesnt exist', ->
    describe 'display', ->
      it 'shows not found', (done) ->
        cleanDB (error) ->
          return done error if error
          whenServerLoaded ->
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
        whenServerLoaded ->
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
        whenServerLoaded ->
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
        whenServerLoaded ->
          page.visit "http://store_1.localhost.com:8000", done
    it 'should display the products', (done) ->
      page.products (p) ->
        p.length.should.equal 2
        done()
