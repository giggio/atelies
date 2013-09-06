require './support/_specHelper'
SiteAdminAuthorizeStoresPage    = require './support/pages/siteAdminAuthorizeStoresPage'
Postman                         = require '../../app/models/postman'
Store                           = require '../../app/models/store'

describe 'Site Admin Authorize Stores page', ->
  page = adminUser = user = store2 = store1 = userSeller = null
  before (done) ->
    page = new SiteAdminAuthorizeStoresPage()
    whenServerLoaded done
  setDb = (done) ->
    cleanDB (error) ->
      return done error if error
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
      done()

  describe 'shows stores to authorize', ->
    before (done) ->
      setDb ->
        page.loginFor adminUser._id, ->
          page.visit done
    it 'shows one store to authorize', (done) ->
      page.storesToAuthorize (stores) ->
        stores.length.should.equal 2
        done()
    it 'shows one store to unauthorize', (done) ->
      page.storesToUnauthorize (stores) ->
        stores.length.should.equal 2
        done()
   
  describe 'authorizing', ->
    before (done) ->
      setDb ->
        Postman.sentMails.length = 0
        page.loginFor adminUser._id, ->
          page.visit ->
            page.clickAuthorize store2, done
    it 'removed the store from the view', (done) ->
      page.storesToAuthorize (stores) ->
        stores.length.should.equal 1
        done()
    it 'unauthorized the store on the db', (done) ->
      Store.findById store2._id, (err, store) ->
        store.isFlyerAuthorized.should.be.true
        done()
    it 'sent an email to store admins informing', ->
      Postman.sentMails.length.should.equal 1
      mail = Postman.sentMails[0]
      mail.to.should.equal "'#{userSeller.name}' <#{userSeller.email}>"
      mail.subject.should.equal "Ateliês: A loja #{store2.name} teve seu flyer aprovado"
   
  describe 'unauthorizing', ->
    before (done) ->
      setDb ->
        Postman.sentMails.length = 0
        page.loginFor adminUser._id, ->
          page.visit ->
            page.clickUnauthorize store1, done
    it 'removed the store from the view', (done) ->
      page.storesToUnauthorize (stores) ->
        stores.length.should.equal 1
        done()
    it 'authorized the store on the db', (done) ->
      Store.findById store1._id, (err, store) ->
        store.isFlyerAuthorized.should.be.false
        done()
    it 'sent an email to store admins informing', ->
      Postman.sentMails.length.should.equal 1
      mail = Postman.sentMails[0]
      mail.to.should.equal "'#{userSeller.name}' <#{userSeller.email}>"
      mail.subject.should.equal "Ateliês: A loja #{store1.name} teve seu flyer reprovado"
