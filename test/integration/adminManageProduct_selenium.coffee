require './support/_specHelper'
Store     = require '../../app/models/store'
Product   = require '../../app/models/product'
User      = require '../../app/models/user'
webdriver = require 'selenium-webdriver'
chromedriver = require 'chromedriver'

webdriver.WebElement::type = (text) ->
  @clear().then => @sendKeys text

describe 'Admin Manage Product page', ->
  page = product = product2 = store = userSeller = browser = page = null
  before (done) ->
    cleanDB (error) ->
      return done error if error
      whenServerLoaded ->
        store = generator.store.a()
        store.save()
        product = generator.product.a()
        product.save()
        product2 = generator.product.d()
        product2.save()
        userSeller = generator.user.c()
        userSeller.stores.push store
        userSeller.save()
        done()

  describe 'editing product', ->
    driverProcess = driver = otherProduct = null
    before (done) ->
      otherProduct = generator.product.b()
      chromedriver.start()
      driver = new webdriver.Builder()
        .usingServer('http://localhost:9515')
        .build()
      driver.manage().timeouts().implicitlyWait 5000
      driver.get "http://localhost:8000/account/login"
      driver.findElement(webdriver.By.css('#loginForm #email')).type userSeller.email
      driver.findElement(webdriver.By.css('#loginForm #password')).type userSeller.password
      driver.findElement(webdriver.By.css('#loginForm #login')).click()
      driver.get "http://localhost:8000/admin#manageProduct/#{store.slug}/#{product._id.toString()}"
      driver.findElement(webdriver.By.css('#name')).type otherProduct.name
      driver.findElement(webdriver.By.css("#price")).type otherProduct.price
      driver.findElement(webdriver.By.css("#picture")).type otherProduct.picture
      driver.findElement(webdriver.By.css("#tags")).type otherProduct.tags?.join ","
      driver.findElement(webdriver.By.css("#description")).type 'abcdef'
      driver.findElement(webdriver.By.css("#height")).type otherProduct.dimensions?.height
      driver.findElement(webdriver.By.css("#width")).type otherProduct.dimensions?.width
      driver.findElement(webdriver.By.css("#depth")).type otherProduct.dimensions?.depth
      driver.findElement(webdriver.By.css("#weight")).type otherProduct.weight
      driver.findElement(webdriver.By.css("#inventory")).type otherProduct.inventory
      driver.findElement(webdriver.By.css('#updateProduct')).click().then done, done
    after (done) ->
      driver.quit().then ->
        chromedriver.stop()
        done()
    it 'is at the store manage page', (done) ->
      driver.getCurrentUrl().then (url) ->
        url.should.equal "http://localhost:8000/admin#store/#{product.storeSlug}"
        done()
    it 'updated the product', (done) ->
      Product.findById product._id, (err, productOnDb) ->
        return done err if err
        productOnDb.name.should.equal otherProduct.name
        productOnDb.price.should.equal otherProduct.price
        productOnDb.picture.should.equal otherProduct.picture
        productOnDb.tags.should.be.like otherProduct.tags
        productOnDb.description.should.equal 'abcdef'
        productOnDb.dimensions.height.should.equal otherProduct.dimensions.height
        productOnDb.dimensions.width.should.equal otherProduct.dimensions.width
        productOnDb.dimensions.depth.should.equal otherProduct.dimensions.depth
        productOnDb.weight.should.equal otherProduct.weight
        productOnDb.hasInventory.should.equal otherProduct.hasInventory
        productOnDb.inventory.should.equal otherProduct.inventory
        done()
