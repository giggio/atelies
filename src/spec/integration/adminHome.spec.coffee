zombie    = new require 'zombie'

describe 'Admin home page', ->
  browser = page = store1 = store2 = null
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
    stores = page.stores()
    expect(stores[0].url).toBe "#manageStore/#{store1.slug}"
    expect(stores[1].url).toBe "#manageStore/#{store2.slug}"
