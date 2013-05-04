Store     = require '../../models/store'
Product   = require '../../models/product'

describe 'Store product page', ->
  browser = null
  afterAll -> browser.destroy() if browser?
  describe 'regular product', ->
    store = product1 = null
    beforeAll (done) ->
      browser = newBrowser browser
      cleanDB (error) ->
        return done error if error
        store = generator.store.a()
        store.save()
        product1 = generator.product.a()
        product1.save()
        whenServerLoaded ->
          browser.storeProductPage.visit "store_1", "name_1", done
    it 'should show the product name', ->
      expect(browser.text("#product#{product1._id} #name")).toBe product1.name
    it 'should show the product picture', ->
      expect(browser.query("#product#{product1._id} #picture").src).toBe product1.picture
    it 'should show the product price', ->
      expect(browser.text("#product#{product1._id} #price")).toBe product1.price.toString()
    it 'should show the product tags', ->
      expect(browser.text("#product#{product1._id} #tags")).toBe 'abc, def'
    it 'should show the product description', ->
      expect(browser.text("#product#{product1._id} #description")).toBe product1.description
    it 'should show the product height', ->
      expect(browser.text("#product#{product1._id} #dimensions #height")).toBe product1.dimensions.height.toString()
    it 'should show the product width', ->
      expect(browser.text("#product#{product1._id} #dimensions #width")).toBe product1.dimensions.width.toString()
    it 'should show the product depth', ->
      expect(browser.text("#product#{product1._id} #dimensions #depth")).toBe product1.dimensions.depth.toString()
    it 'should show the product weight', ->
      expect(browser.text("#product#{product1._id} #weight")).toBe product1.weight.toString()
    it 'shows the product inventory', ->
      expect(browser.text("#product#{product1._id} #inventory")).toBe '30 itens'
    it 'shows the store name', ->
      expect(browser.text('#storeName')).toBe store.name
    it 'does not show store name header', ->
      expect(browser.text('#storeNameHeader')).toBe ''
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
  describe 'store without banner', ->
    store = product1 = browser = null
    beforeAll (done) ->
      browser = newBrowser browser
      cleanDB (error) ->
        return done error if error
        store = generator.store.b()
        store.save()
        product1 = generator.product.c()
        product1.save()
        whenServerLoaded ->
          browser.storeProductPage.visit "store_2", "name_3", done
    it 'does not show the store banner', ->
      expect(browser.query('#storeBanner')).toBeNull()
    it 'shows store name header', ->
      expect(browser.text('#storeNameHeader')).toBe store.name
