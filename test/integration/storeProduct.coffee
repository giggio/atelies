require './support/_specHelper'
Store     = require '../../app/models/store'
Product   = require '../../app/models/product'

describe 'Store product page', ->
  browser = null
  after -> browser.destroy() if browser?
  describe 'regular product', ->
    page = store = product1 = null
    before (done) ->
      browser = newBrowser browser
      cleanDB (error) ->
        return done error if error
        store = generator.store.a()
        store.save()
        product1 = generator.product.a()
        product1.save()
        whenServerLoaded ->
          page = browser.storeProductPage
          page.visit "store_1", "name_1", done
    it 'should show the product name', ->
      expect(browser.text("#product #name")).to.equal product1.name
    it 'should show the product picture', ->
      expect(browser.query("#product #picture").src).to.equal product1.picture
    it 'should show the product price', ->
      expect(browser.text("#product #price")).to.equal product1.price.toString()
    it 'should show the product tags', ->
      expect(browser.text("#product .tag")).to.equal 'abcdef'
    it 'should show the product description', ->
      expect(browser.text("#product #description")).to.equal product1.description
    it 'should show the product height', ->
      expect(browser.text("#product #dimensions #height")).to.equal product1.dimensions.height.toString()
    it 'should show the product width', ->
      expect(browser.text("#product #dimensions #width")).to.equal product1.dimensions.width.toString()
    it 'should show the product depth', ->
      expect(browser.text("#product #dimensions #depth")).to.equal product1.dimensions.depth.toString()
    it 'should show the product weight', ->
      expect(browser.text("#product #weight")).to.equal product1.weight.toString()
    it 'shows the product inventory', ->
      expect(browser.text("#product #inventory")).to.equal '30 itens'
    it 'shows the store name', ->
      expect(browser.text('#storeName')).to.equal store.name
    it 'does not show store name header', ->
      expect(browser.text('#storeNameHeader')).to.equal ''
    it 'shows phone number', ->
      expect(browser.text('#storePhoneNumber')).to.equal store.phoneNumber
    it 'shows City', ->
      expect(browser.text('#storeCity')).to.equal store.city
    it 'shows State', ->
      expect(browser.text('#storeState')).to.equal store.state
    it 'shows other store url', ->
      expect(browser.text('#storeOtherUrl')).to.equal store.otherUrl
    it 'shows store banner', ->
      expect(browser.query('#storeBanner').src).to.equal store.banner
  describe 'store without banner', ->
    store = product1 = browser = null
    before (done) ->
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
      expect(browser.query('#storeBanner')).to.be.null
    it 'shows store name header', ->
      expect(browser.text('#storeNameHeader')).to.equal store.name
