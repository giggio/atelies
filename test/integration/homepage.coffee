require './support/_specHelper'
Product   = require '../../app/models/product'
Store     = require '../../app/models/store'
HomePage  = require './support/pages/homePage'
_         = require 'underscore'
Q         = require 'q'

describe 'Home page', ->
  page = null
  before ->
    page = new HomePage()
    whenServerLoaded()
  describe "only authorized stores with 7 products or more", ->
    before ->
      cleanDB()
      .then ->
        saving = for i in [0..11]
          do (i) ->
            s = generator.store.a()
            s.name+=i
            s.isFlyerAuthorized = true
            savingProduct = for i in [0..6]
              p = generator.product.a()
              p.storeSlug = s.slug
              p.name+="#{s.name}_#{i}_#{p.name}"
              Q.ninvoke p, 'save'
            Q.all savingProduct
            .then -> s.calculateProductCount()
        Q.all saving
      .then ->
        saving = for i in [12..23]
          s = generator.store.a()
          s.name+=i + " noproduct"
          s.isFlyerAuthorized = true
          Q.ninvoke s,'save'
        Q.all saving
      .then -> page.visit()
    it 'has twelve products', -> page.productsLength().should.become 12
    it 'shows a saved product', ->
      page.firstProductId()
      .then (id) -> Q.ninvoke Product, 'findById', id
      .then (product) ->
        page.product(product._id).then (p) ->
          p._id.should.equal product._id.toString()
          p.storeName.should.equal product.storeName
          p.picture.should.equal product.picture + "_thumb150x150"
          p.slug.endsWith(product.slug).should.be.true
    it 'limits the number of stores in 12', -> page.storesLength().should.become 12
    it 'does not show stores without at least 7 products', ->
      page.stores().then (stores) -> store.name.should.not.match /noproduct$/ for store in stores
    it 'links picture to a saved store', ->
      page.firstStoreId()
      .then (id) -> Q.ninvoke Store, 'findById', id
      .then (store) ->
        page.storeLink(store._id)
        .then (href) -> href.endsWith(store.slug).should.be.true

  describe "with some stores authorized and some unauthorized flyers with 7 products or more", ->
    unauthorizedStores = authorizedStores = null
    before ->
      cleanDB()
      .then ->
        unauthorizedStores = []
        saving = for i in [0..11]
          do (i) ->
            s = generator.store.a()
            unauthorizedStores.push s
            s.name+="_"+i
            s.isFlyerAuthorized = if i > 5 then undefined else false
            Q.ninvoke s, 'save'
            .then ->
              savingProduct = for i in [0..6]
                p = generator.product.a()
                p.storeSlug = s.slug
                p.name+="#{s.name}_#{i}_#{p.name}"
                Q.ninvoke p, 'save'
              Q.all savingProduct
            .then -> s.calculateProductCount()
        Q.all saving
      .then ->
        authorizedStores = []
        saving = for i in [12..23]
          do (i) ->
            s = generator.store.a()
            authorizedStores.push s
            s.name+="_"+i
            s.isFlyerAuthorized = true
            Q.ninvoke s, 'save'
            .then ->
              savingProduct = for i in [0..6]
                p = generator.product.a()
                p.storeSlug = s.slug
                p.name+="#{s.name}_#{i}_#{p.name}"
                Q.ninvoke p, 'save'
              Q.all savingProduct
            .then -> s.calculateProductCount()
        Q.all saving
      .then -> page.visit()
    it 'limits the number of stores in 12', -> page.storesLength().should.become 12
    it 'shows only authorized stores', ->
      authorizedIds = _.map authorizedStores, (s) -> s._id.toString()
      unauthorizedIds = _.map unauthorizedStores, (s) -> s._id.toString()
      page.storesIds().then (ids) ->
        for id in ids
          authorizedIds.should.contain id
          unauthorizedIds.should.not.contain id
