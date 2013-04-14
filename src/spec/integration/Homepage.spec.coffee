Product   = require '../../models/product'
zombie    = new require('zombie')

describe 'Home page', ->
  browser = null
  product1 = null
  product2 = null
  eachCalled = false
  beforeEach (done) ->
    if eachCalled
      return done()
    eachCalled = true
    browser = new zombie.Browser()
    cleanDB (error) ->
      if error
        return done error
      product1 = new Product(name: 'name 1', slug: 'name_1', picture: 'http://lorempixel.com/150/150/cats', price: 11.1, storeName: 'store 1', storeSlug: 'store_1')
      product2 = new Product(name: 'name 2', slug: 'name_2', picture: 'http://lorempixel.com/150/150/cats', price: 12.2, storeName: 'store 2', storeSlug: 'store_2')
      product1.save()
      product2.save()
      whenServerLoaded ->
        browser.visit "http://localhost:8000/", (error) ->
          if error
            console.error "Error visiting. " + error.stack
            done error
          else
            done()
  it 'answers with 200', ->
    expect(browser.success).toBeTruthy()
  it 'has two products', ->
    expect(browser.query('#productsHome tbody').children.length).toBe 2
  it 'shows product 1', ->
    expect(browser.text('#' + product1._id)).toBe product1._id.toString()
  it 'shows store name for product 1', ->
    expect(browser.text("##{product1._id}_store")).toBe 'store 1'
  it 'shows store slug for product 1', ->
    expect(browser.query("##{product1._id}_store a").href).toEndWith 'store_1'
  it 'shows slug for product 1', ->
    expect(browser.query("##{product1._id}_name a").href).toEndWith 'store_1/name_1'
  it 'shows picture for product 1', ->
    expect(browser.query("##{product1._id}_picture").src).toBe 'http://lorempixel.com/150/150/cats'
