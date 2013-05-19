require './support/_specHelper'
Product   = require '../../app/models/product'

describe 'Home page', ->
  browser = product1 = product2 = null
  before (done) ->
    browser = newBrowser()
    cleanDB (error) ->
      if error
        return done error
      product1 = generator.product.b()
      product2 = generator.product.c()
      product1.save()
      product2.save()
      whenServerLoaded ->
        browser.homePage.visit (error) -> doneError error, done
  after ->
    browser.destroy()
  it 'answers with 200', ->
    expect(browser.success).to.be.true
  it 'has two products', ->
    expect(browser.query('#productsHome tbody').children.length).to.equal 2
  it 'shows product 1', ->
    expect(browser.text("#product#{product1._id}")).to.equal product1._id.toString()
  it 'shows store name for product 1', ->
    expect(browser.text("#product#{product1._id}_store")).to.equal product1.storeName
  it 'links store to store page for product 1', ->
    expect(browser.query("#product#{product1._id}_store a").href.endsWith product1.storeSlug).to.be.true
  it 'links product name to product page for product 1', ->
    expect(browser.query("#product#{product1._id}_name a").href.endsWith product1.url()).to.be.true
  it 'shows picture for product 1', ->
    expect(browser.query("#product#{product1._id}_picture img").src).to.equal product1.picture
  it 'links picture to product page for product 1', ->
    expect(browser.query("#product#{product1._id}_picture").href.endsWith product1.slug).to.be.true
