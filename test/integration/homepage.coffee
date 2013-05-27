require './support/_specHelper'
Product   = require '../../app/models/product'

describe 'Home page', ->
  browser = store1 = store2 = product1 = product2 = null
  before (done) ->
    browser = newBrowser()
    cleanDB (error) ->
      if error
        return done error
      product1 = generator.product.b()
      product2 = generator.product.c()
      product1.save()
      product2.save()
      store1 = generator.store.a()
      store2 = generator.store.b()
      store1.save()
      store2.save()
      whenServerLoaded ->
        browser.homePage.visit (error) -> doneError error, done
  after ->
    browser.destroy()
  it 'answers with 200', ->
    expect(browser.success).to.be.true
  it 'has two products', ->
    expect(browser.queryAll('#products .product').length).to.equal 2
  it 'shows product 1', ->
    expect(browser.query("#product#{product1._id}").getAttribute('data-id')).to.equal product1._id.toString()
  it 'shows store name for product 1', ->
    expect(browser.text("#product#{product1._id}_storeName")).to.equal product1.storeName
  it 'shows picture for product 1', ->
    expect(browser.query("#product#{product1._id}_picture img").src).to.equal product1.picture
  it 'links picture to product page for product 1', ->
    expect(browser.query("#product#{product1._id}_picture").href.endsWith product1.slug).to.be.true
  it 'shows stores', ->
    expect(browser.queryAll('#stores .store').length).to.equal 2
  it 'links picture to store 1', ->
    expect(browser.query("#store#{store1._id} .link").href.endsWith store1.slug).to.be.true
