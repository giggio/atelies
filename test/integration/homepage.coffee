require './support/_specHelper'
Product   = require '../../app/models/product'
HomePage  = require './support/pages/homePage'
_         = require 'underscore'

describe 'Home page', ->
  page = store1 = store2 = product1 = product2 = null
  before ->
    page = new HomePage()
    whenServerLoaded()
  describe "only authorized stores", ->
    before ->
      cleanDB().then ->
        product1 = generator.product.b()
        product2 = generator.product.c()
        product1.save()
        product2.save()
        for i in [0..9]
          p = generator.product.a()
          p.name+=i
          p.save()
        store1 = generator.store.a()
        store1.isFlyerAuthorized = true
        store2 = generator.store.b()
        store2.isFlyerAuthorized = true
        store1.save()
        store2.save()
        for i in [0..9]
          s = generator.store.a()
          s.name+=i
          s.isFlyerAuthorized = true
          s.save()
        page.visit()
    it 'has twelve products', ->
      page.productsLength (l) ->
        l.should.equal 12
    it 'shows product 1', ->
      page.product product1._id, (p) ->
        p._id.should.equal product1._id.toString()
        p.storeName.should.equal product1.storeName
        p.picture.should.equal product1.picture + "_thumb150x150"
        p.slug.endsWith(product1.slug).should.be.true
    it 'shows stores', ->
      page.storesLength (l) ->
        l.should.equal 12
    it 'links picture to store 1', ->
      page.storeLink store1._id, (href) ->
        href.endsWith(store1.slug).should.be.true

  describe "with some stores authorized and some unauthorized flyers", ->
    unauthorizedStores = authorizedStores = null
    before ->
      cleanDB().then ->
        product1 = generator.product.b()
        product2 = generator.product.c()
        product1.save()
        product2.save()
        for i in [0..9]
          p = generator.product.a()
          p.name+=i
          p.save()
        unauthorizedStores =
          for i in [0..11]
            s = generator.store.a()
            s.name+=i
            if i > 5
              s.isFlyerAuthorized = undefined
            else
              s.isFlyerAuthorized = false
            s.save()
            s
        authorizedStores =
          for i in [12..23]
            s = generator.store.a()
            s.name+=i
            s.isFlyerAuthorized = true
            s.save()
            s
        page.visit()
    it 'shows stores', -> page.storesLength().should.become 12
    it 'shows only authorized stores', ->
      authorizedIds = _.map authorizedStores, (s) -> s._id.toString()
      unauthorizedIds = _.map unauthorizedStores, (s) -> s._id.toString()
      page.storesIds().then (ids) ->
        for id in ids
          authorizedIds.should.contain id
          unauthorizedIds.should.not.contain id
