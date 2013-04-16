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
      product1 = new Product
        name: 'name 1'
        slug: 'name_1'
        picture: 'http://lorempixel.com/300/450/cats'
        price: 11.1
        storeName: 'store 1'
        storeSlug: 'store_1'
        tags: ['abc', 'def']
        description: "Mussum ipsum cacilds, vidis litro abertis. Consetis adipiscings elitis. Pra lá , depois divoltis porris, paradis. Paisis, filhis, espiritis santis. Mé faiz elementum girarzis, nisi eros vermeio, in elementis mé pra quem é amistosis quis leo. Manduma pindureta quium dia nois paga. Sapien in monti palavris qui num significa nadis i pareci latim. Interessantiss quisso pudia ce receita de bolis, mais bolis eu num gostis."
        dimensions:
          height: 10
          width: 20
          depth: 30
        weight: 40
        hasInventory: true
        inventory: 30
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
