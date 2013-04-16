Store     = require '../../models/store'
Product   = require '../../models/product'
zombie    = new require 'zombie'

describe 'store product page', ->
  eachCalled = false
  product1 = browser = null
  beforeEach (done) ->
    return done() if eachCalled
    eachCalled = true
    browser = new zombie.Browser()
    cleanDB (error) ->
      return done error if error
      store = new Store name: 'store 1', slug: 'store_1'
      store.save()
      product1 = new Product(name: 'name 1', slug: 'name_1', picture: 'http://lorempixel.com/150/150/cats', price: 11.1, storeName: 'store 1', storeSlug: 'store_1')
      product2 = new Product(name: 'name 2', slug: 'name_2', picture: 'http://lorempixel.com/150/150/cats', price: 12.2, storeName: 'store 1', storeSlug: 'store_1')
      product1.save()
      product2.save()
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
    expect(browser.text('#product #tags')).toBe product1.tags
  it 'should show the product description', ->
    expect(browser.text('#product #description')).toBe product1.description
  it 'should show the product height', ->
    expect(browser.text('#product #dimensions #height')).toBe product1.dimenstions.height.toString()
  it 'should show the product width', ->
    expect(browser.text('#product #dimensions #width')).toBe product1.dimensions.width.toString()
  it 'should show the product depth', ->
    expect(browser.text('#product #dimensions #depth')).toBe product1.dimensions.depth.toString()
  it 'should show the product weight', ->
    expect(browser.text('#product #weight')).toBe product1.weight.toString()
  it 'should show if the product has inventory', ->
    expect(browser.text('#product #hasInventory')).toBe product1.hasInventory
