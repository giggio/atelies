require './support/_specHelper'
SiteAdminAuthorizeStoresPage    = require './support/pages/siteAdminAuthorizeStoresPage'
Postman                         = require '../../app/models/postman'
Store                           = require '../../app/models/store'
Q                               = require 'q'

describe 'Site Admin Authorize Stores page', ->
  page = adminUser = user = store2 = store1 = userSeller = null
  before ->
    page = new SiteAdminAuthorizeStoresPage()
    whenServerLoaded()
  setDb = ->
    cleanDB().then ->
      adminUser = generator.user.a()
      adminUser.isAdmin = true
      adminUser.save()
      store1 = generator.store.a()
      store1.isFlyerAuthorized = undefined
      store1.save()
      store2 = generator.store.b()
      store2.isFlyerAuthorized = undefined
      store2.save()
      store3 = generator.store.c()
      store3.isFlyerAuthorized = true
      store3.save()
      store4 = generator.store.d()
      store4.isFlyerAuthorized = false
      store4.save()
      userSeller = generator.user.a()
      userSeller.stores.push store1
      userSeller.stores.push store2
      userSeller.save()

  describe 'shows stores to authorize', ->
    before ->
      setDb()
      .then -> page.loginFor adminUser._id
      .then page.visit
    it 'shows one store to authorize', -> page.storesToAuthorize().then(captureAttribute "length").should.eventually.equal 2
    it 'shows one store to unauthorize', -> page.storesToUnauthorize().then(captureAttribute "length").should.eventually.equal 2
   
  describe 'authorizing', ->
    before ->
      setDb()
      .then ->
        Postman.sentMails.length = 0
        page.loginFor adminUser._id
      .then page.visit
      .then -> page.clickAuthorize store2
    it 'removed the store from the view', -> page.storesToAuthorize().then(captureAttribute "length").should.eventually.equal 1
    it 'unauthorized the store on the db', -> Q.ninvoke(Store, "findById", store2._id).then(captureAttribute "isFlyerAuthorized").should.eventually.be.true
    it 'sent an email to store admins informing', ->
      Postman.sentMails.length.should.equal 1
      mail = Postman.sentMails[0]
      mail.to.should.equal "#{userSeller.name} <#{userSeller.email}>"
      mail.subject.should.equal "Ateliês: A loja #{store2.name} teve seu flyer aprovado"
   
  describe 'unauthorizing', ->
    before ->
      setDb().then ->
        Postman.sentMails.length = 0
        page.loginFor adminUser._id
      .then page.visit
      .then -> page.clickUnauthorize store1
    it 'removed the store from the view', -> page.storesToUnauthorize().then (ss) -> ss.length.should.equal 1
    it 'authorized the store on the db', -> Q.ninvoke(Store, "findById", store1._id).then(captureAttribute "isFlyerAuthorized").should.eventually.be.false
    it 'sent an email to store admins informing', ->
      Postman.sentMails.length.should.equal 1
      mail = Postman.sentMails[0]
      mail.to.should.equal "#{userSeller.name} <#{userSeller.email}>"
      mail.subject.should.equal "Ateliês: A loja #{store1.name} teve seu flyer reprovado"
