Product   = require '../../models/product'

describe 'Home page', ->
  browser = product1 = product2 = null
  beforeAll (done) ->
    browser = newBrowser()
    cleanDB (error) ->
      if error
        return done error
      product1 = generator.product.b()
      product2 = generator.product.c()
      product1.save()
      product2.save()
      whenServerLoaded ->
        browser.visit "http://localhost:8000/", (error) -> doneError error, done
  afterAll ->
    browser.destroy()
  it 'answers with 200', ->
    expect(browser.success).toBeTruthy()
  it 'has two products', ->
    expect(browser.query('#productsHome tbody').children.length).toBe 2
  it 'shows product 1', ->
    expect(browser.text("#product#{product1._id}")).toBe product1._id.toString()
  it 'shows store name for product 1', ->
    expect(browser.text("#product#{product1._id}_store")).toBe product1.storeName
  it 'links store to store page for product 1', ->
    expect(browser.query("#product#{product1._id}_store a").href).toEndWith product1.storeSlug
  it 'links product name to product page for product 1', ->
    expect(browser.query("#product#{product1._id}_name a").href).toEndWith product1.url()
  it 'shows picture for product 1', ->
    expect(browser.query("#product#{product1._id}_picture img").src).toBe product1.picture
  it 'links picture to product page for product 1', ->
    expect(browser.query("#product#{product1._id}_picture").href).toEndWith product1.slug
