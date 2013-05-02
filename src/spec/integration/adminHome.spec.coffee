zombie    = new require 'zombie'

xdescribe 'Admin home page', ->
  browser = null
  page = null
  beforeAll (done) ->
    browser = newBrowser()
    page = browser.adminHomePage
    cleanDB (error) ->
      return done error if error
      store1 = generator.store.a()
      store1.save()
      store2 = generator.store.b()
      store2.save()
      whenServerLoaded ->
        page.visit done
  it 'allows to create a new store', ->
    expect(page.createStoreLinkText()).toBe 'Crie uma nova loja'
  it 'shows existing stores to manage', ->
    expect(page.storesQuantity()).toBe 2
  it 'links to store manage pages', ->
    expect(page.stores[0].url).toBe "http://localhost:3000/admin#manageStore/#{store1.slug}"
    expect(page.stores[1].url).toBe "http://localhost:3000/admin#manageStore/#{store2.slug}"
