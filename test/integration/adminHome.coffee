require './support/_specHelper'
AdminHomePage                = require './support/pages/adminHomePage'

describe 'Admin home page', ->
  userSeller = userNonSeller = store1 = store2 = null
  before (done) ->
    cleanDB (error) ->
      return done error if error
      store1 = generator.store.a()
      store1.save()
      store2 = generator.store.b()
      store2.save()
      store3 = generator.store.c()
      store3.save()
      userNonSeller = generator.user.a()
      userNonSeller.save()
      userSeller = generator.user.c()
      userSeller.stores.push store1
      userSeller.stores.push store2
      userSeller.save()
      whenServerLoaded done

  describe 'accessing with a logged in and seller user', ->
    page = null
    before (done) ->
      page = new AdminHomePage()
      page.loginFor userSeller._id, ->
        page.visit done
    it 'allows to create a new store', (done) ->
      page.createStoreText (t) ->
        t.should.equal 'Crie uma nova loja'
        done()
    it 'shows existing user stores to manage', (done) ->
      page.storesQuantity (q) -> q.should.equal 2; done()
    it 'links to store manage pages', (done) ->
      page.stores (stores) =>
        stores[0].url.should.equal "http://localhost:8000/admin/store/#{store1.slug}"
        stores[1].url.should.equal "http://localhost:8000/admin/store/#{store2.slug}"
        done()

  describe 'accessing with a logged in but not a seller user', ->
    page = null
    before (done) ->
      page = new AdminHomePage()
      page.loginFor userNonSeller._id, ->
        page.visit done
    it 'redirects user to login', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/notseller"
        done()

  describe 'accessing with an anonymous user', ->
    page = null
    before (done) ->
      page = new AdminHomePage()
      page.clearCookies ->
        page.visit done
    it 'redirects user to login', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/account/login?redirectTo=/admin/"
        done()
