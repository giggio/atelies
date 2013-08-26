require './support/_specHelper'
Store                           = require '../../app/models/store'
Product                         = require '../../app/models/product'
StoreFinishOrderShippingPage    = require './support/pages/storeFinishOrderShippingPage'
StoreCartPage                   = require './support/pages/storeCartPage'
StoreProductPage                = require './support/pages/storeProductPage'
AccountUpdateProfilePage        = require  './support/pages/accountUpdateProfilePage'
LoginPage                       = require  './support/pages/loginPageSelenium'

describe 'Store Finish Order: Shipping', ->
  page = productNoShipping = loginPage = accountUpdateProfilePage = storeCartPage = storeProductPage = store = product1 = product2 = store2 = user1 = userIncompleteAddress = null
  after (done) -> page.closeBrowser done
  before (done) =>
    page = new StoreFinishOrderShippingPage()
    storeCartPage = new StoreCartPage page
    storeProductPage = new StoreProductPage page
    accountUpdateProfilePage = new AccountUpdateProfilePage page
    loginPage = new LoginPage page
    cleanDB (error) ->
      return done error if error
      store = generator.store.a()
      store.save()
      product1 = generator.product.a()
      product1.save()
      product2 = generator.product.b()
      product2.save()
      user1 = generator.user.d()
      user1.save()
      userIncompleteAddress = generator.user.a()
      userIncompleteAddress.save()
      store2 = generator.store.b()
      store2.save()
      productNoShipping = generator.product.c()
      productNoShipping.save()
      whenServerLoaded done

  describe 'logged in user with full address', ->
    before (done) ->
      page.clearLocalStorage ->
        page.loginFor user1._id, ->
          storeProductPage.visit 'store_1', 'name_1', ->
            storeProductPage.purchaseItem ->
              storeCartPage.clickFinishOrder done
    it 'should show address', (done) ->
      page.address (a) ->
        userAddress = user1.deliveryAddress
        a.street.should.equal userAddress.street
        a.street2.should.equal userAddress.street2
        a.city.should.equal userAddress.city
        a.state.should.equal userAddress.state
        a.zip.should.equal userAddress.zip
        done()
    it 'should show calculated shipping', (done) ->
      page.shippingInfo (s) ->
        s.options.length.should.equal 2
        done()
    it 'does not have next button enabled', (done) ->
      page.finishOrderButtonIsEnabled (itIs) ->
        itIs.should.equal false
        done()
    it 'does not show message about shipping manual calculation', (done) ->
      page.manualShippingCalculationMessage (m) ->
        expect(m).to.be.null
        done()

  describe 'product without shipping charge', ->
    before (done) ->
      page.clearLocalStorage ->
        page.loginFor user1._id, ->
          storeProductPage.visit 'store_1', 'name_2', ->
            storeProductPage.purchaseItem ->
              storeCartPage.clickFinishOrder done
    it 'should show calculated shipping', (done) ->
      page.shippingInfo (s) ->
        s.options.length.should.equal 2
        s.options[0].text.should.equal "3 dia(s) - PAC - R$ 0,00"
        s.options[1].text.should.equal "1 dia(s) - Sedex - R$ 0,00"
        done()
    it 'does not show message about shipping manual calculation', (done) ->
      page.manualShippingCalculationMessage (m) ->
        expect(m).to.be.null
        done()

  describe 'not logged in user', (done) ->
    before (done) ->
      page.clearCookies ->
        page.clearLocalStorage ->
          storeProductPage.visit 'store_1', 'name_1', ->
            storeProductPage.purchaseItem ->
              storeCartPage.clickFinishOrder done
    it 'should be redirected to login', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/account/login?redirectTo=/#{store.slug}%23finishOrder/shipping"
        done()

  describe 'logged in user with incomplete address', ->
    before (done) ->
      page.clearLocalStorage ->
        page.loginFor userIncompleteAddress._id, ->
          storeProductPage.visit 'store_1', 'name_1', ->
            storeProductPage.purchaseItem ->
              storeCartPage.clickFinishOrder done
    it 'should redirect to update profile page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/#{store.slug}#finishOrder/updateProfile"
        done()

  describe 'logged in user with incomplete address completes address and comes back to the store and cart', ->
    before (done) ->
      page.clearLocalStorage ->
        page.loginFor userIncompleteAddress._id, ->
          storeProductPage.visit 'store_1', 'name_1', ->
            storeProductPage.purchaseItem ->
              storeCartPage.clickFinishOrder ->
                page.pressButton "#updateProfile", ->
                  accountUpdateProfilePage.setFieldsAs user1, ->
                    accountUpdateProfilePage.clickUpdateProfileButton ->
                      page.pressButton "#redirectTo", done
    it 'should take back to the shipping page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/#{store.slug}#finishOrder/shipping"
        done()
    it 'should show address', (done) ->
      page.address (a) ->
        userAddress = user1.deliveryAddress
        a.street.should.equal userAddress.street
        a.street2.should.equal userAddress.street2
        a.city.should.equal userAddress.city
        a.state.should.equal userAddress.state
        a.zip.should.equal userAddress.zip
        done()

  describe 'a not logged in user logs in and comes back to the store and cart', ->
    before (done) ->
      page.clearCookies ->
        page.clearLocalStorage ->
          storeProductPage.visit 'store_1', 'name_1', ->
            storeProductPage.purchaseItem ->
              storeCartPage.clickFinishOrder ->
                loginPage.loginWith user1, done
    it 'should take back to the shipping page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/#{store.slug}#finishOrder/shipping"
        done()
    it 'should show address', (done) ->
      page.address (a) ->
        userAddress = user1.deliveryAddress
        a.street.should.equal userAddress.street
        a.street2.should.equal userAddress.street2
        a.city.should.equal userAddress.city
        a.state.should.equal userAddress.state
        a.zip.should.equal userAddress.zip
        done()

  describe 'store with only products without shipping', ->
    before (done) ->
      page.clearLocalStorage ->
        page.loginFor user1._id, ->
          storeProductPage.visit productNoShipping.storeSlug, productNoShipping.slug, ->
            storeProductPage.purchaseItem ->
              storeCartPage.clickFinishOrder done
    it 'should take directly to payment page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/#{productNoShipping.storeSlug}#finishOrder/payment"
        done()
