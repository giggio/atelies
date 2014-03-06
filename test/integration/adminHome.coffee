require './support/_specHelper'
AdminHomePage                = require './support/pages/adminHomePage'

describe 'Admin home page', ->
  userSeller = userNonSeller = store1 = store2 = null
  before ->
    cleanDB().then ->
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
    .then whenServerLoaded

  describe 'accessing with a logged in and seller user', ->
    page = null
    before ->
      page = new AdminHomePage()
      page.loginFor userSeller._id
      .then page.visit
    it 'allows to create a new store', -> page.createStoreText().should.become 'Crie uma nova loja'
    it 'shows existing user stores to manage', -> page.storesQuantity().should.become 2
    it 'links to store manage pages', ->
      page.stores().then (stores) ->
        stores[0].url.should.equal "http://localhost:8000/admin/store/#{store1.slug}"
        stores[1].url.should.equal "http://localhost:8000/admin/store/#{store2.slug}"

  describe 'accessing with a logged in but not a seller user', ->
    page = null
    before ->
      page = new AdminHomePage()
      page.loginFor userNonSeller._id
      .then page.visit
    it 'redirects user to login', -> page.currentUrl().should.become "http://localhost:8000/notseller"

  describe 'accessing with an anonymous user', ->
    page = null
    before ->
      page = new AdminHomePage()
      page.clearCookies()
      .then page.visit
    it 'redirects user to login', -> page.currentUrl().should.become "http://localhost:8000/account/login?redirectTo=/admin/"
