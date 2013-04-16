Store     = require '../../models/store'
Product   = require '../../models/product'
zombie    = new require 'zombie'

describe 'store product page', ->
  eachCalled = false
  store = product1 = browser = null
  beforeEach (done) ->
    return done() if eachCalled
    eachCalled = true
    browser = new zombie.Browser()
    cleanDB (error) ->
      return done error if error
      store = generator.store.a()
      store.save()
      product1 = generator.product.a()
      product1.save()
      whenServerLoaded ->
        browser.visit "http://localhost:8000/store_1#name_1", (error) ->
          if error
            console.error "Error visiting. " + error.stack
            done error
          else
            done()
  it 'should show the product name', ->
    expect(browser.text('#product #name')).toBe product1.name
  it 'should show the product picture', ->
    expect(browser.query('#product #picture').src).toBe product1.picture
  it 'should show the product price', ->
    expect(browser.text('#product #price')).toBe product1.price.toString()
  it 'should show the product tags', ->
    expect(browser.text('#product #tags')).toBe 'abc, def'
  it 'should show the product description', ->
    expect(browser.text('#product #description')).toBe product1.description
  it 'should show the product height', ->
    expect(browser.text('#product #dimensions #height')).toBe product1.dimensions.height.toString()
  it 'should show the product width', ->
    expect(browser.text('#product #dimensions #width')).toBe product1.dimensions.width.toString()
  it 'should show the product depth', ->
    expect(browser.text('#product #dimensions #depth')).toBe product1.dimensions.depth.toString()
  it 'should show the product weight', ->
    expect(browser.text('#product #weight')).toBe product1.weight.toString()
  it 'shows the product inventory', ->
    expect(browser.text('#product #inventory')).toBe '30 itens'
  it 'shows store name', ->
    expect(browser.text('#storeName')).toBe store.name
  it 'shows phone number', ->
    expect(browser.text('#storePhoneNumber')).toBe store.phoneNumber
  it 'shows City', ->
    expect(browser.text('#storeCity')).toBe store.city
  it 'shows State', ->
    expect(browser.text('#storeState')).toBe store.state
  it 'shows other store url', ->
    expect(browser.text('#storeOtherUrl')).toBe store.otherUrl
  it 'shows store banner', ->
    expect(browser.query('#storeBanner').src).toBe store.banner
