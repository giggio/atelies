require './support/_specHelper'
Store                           = require '../../app/models/store'
Product                         = require '../../app/models/product'
StoreFinishOrderShippingPage    = require './support/pages/storeFinishOrderShippingPage'
StoreCartPage                   = require './support/pages/storeCartPage'
StoreProductPage                = require './support/pages/storeProductPage'
AccountUpdateProfilePage        = require  './support/pages/accountUpdateProfilePage'
LoginPage                       = require  './support/pages/loginPage'

describe 'Store Finish Order: Shipping', ->
  page = productNoShipping = loginPage = accountUpdateProfilePage = storeCartPage = storeProductPage = store = product1 = product2 = store2 = user1 = userIncompleteAddress = null
  before ->
    page = new StoreFinishOrderShippingPage()
    storeCartPage = new StoreCartPage page
    storeProductPage = new StoreProductPage page
    accountUpdateProfilePage = new AccountUpdateProfilePage page
    loginPage = new LoginPage page
    cleanDB().then ->
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
      whenServerLoaded()

  describe 'logged in user with full address', ->
    before ->
      page.clearLocalStorage()
      .then -> page.loginFor user1._id
      .then -> storeProductPage.visit 'store_1', 'name_1'
      .then storeProductPage.purchaseItem
      .then storeCartPage.clickFinishOrder
    it 'should show address', ->
      page.address().then (a) ->
        userAddress = user1.deliveryAddress
        a.street.should.equal userAddress.street
        a.street2.should.equal userAddress.street2
        a.city.should.equal userAddress.city
        a.state.should.equal userAddress.state
        a.zip.should.equal userAddress.zip
    it 'should show calculated shipping', ->
      page.shippingInfo().then (s) ->
        s.length.should.equal 2
        s[0].should.be.like value: 'pac', text: '3 dia(s) - PAC - R$ 16,10'
        s[1].should.be.like value: 'sedex', text: '1 dia(s) - Sedex - R$ 20,10'

    it 'does not have next button enabled', -> page.finishOrderButtonIsEnabled().should.eventually.be.false
    it 'does not show message about shipping manual calculation', -> page.manualShippingCalculationMessage().then (m) -> expect(m).to.be.null

  describe 'product without shipping charge', ->
    before ->
      page.clearLocalStorage()
      .then -> page.loginFor user1._id
      .then -> storeProductPage.visit 'store_1', 'name_2'
      .then storeProductPage.purchaseItem
      .then storeCartPage.clickFinishOrder
    it 'should show calculated shipping', ->
      page.shippingInfo().then (s) ->
        s.length.should.equal 2
        s[0].text.should.equal "3 dia(s) - PAC - R$ 0,00"
        s[1].text.should.equal "1 dia(s) - Sedex - R$ 0,00"
    it 'does not show message about shipping manual calculation', -> page.manualShippingCalculationMessage().then (m) -> expect(m).to.be.null

  describe 'not logged in user', ->
    before ->
      page.clearCookies()
      .then -> page.clearLocalStorage
      .then -> storeProductPage.visit 'store_1', 'name_1'
      .then storeProductPage.purchaseItem
      .then storeCartPage.clickFinishOrder
    it 'should be redirected to login', -> page.currentUrl().should.become "http://localhost:8000/account/login?redirectTo=/#{store.slug}/finishOrder/shipping"

  describe 'logged in user with incomplete address', ->
    before ->
      page.clearLocalStorage()
      .then -> page.loginFor userIncompleteAddress._id
      .then -> storeProductPage.visit 'store_1', 'name_1'
      .then storeProductPage.purchaseItem
      .then storeCartPage.clickFinishOrder
    it 'should redirect to update profile page', -> page.currentUrl().should.become "http://localhost:8000/#{store.slug}/finishOrder/updateProfile"

  describe 'logged in user with incomplete address completes address and comes back to the store and cart', ->
    before ->
      page.clearLocalStorage()
      .then -> page.loginFor userIncompleteAddress._id
      .then -> storeProductPage.visit 'store_1', 'name_1'
      .then storeProductPage.purchaseItem
      .then storeCartPage.clickFinishOrder
      .then -> page.pressButton "#updateProfile"
      .then -> accountUpdateProfilePage.setFieldsAs user1
      .then accountUpdateProfilePage.clickUpdateProfileButton
      .then -> page.pressButton "#redirectTo"
    it 'should take back to the shipping page', -> page.currentUrl().should.become "http://localhost:8000/#{store.slug}/finishOrder/shipping"
    it 'should show address', ->
      page.address().then (a) ->
        userAddress = user1.deliveryAddress
        a.street.should.equal userAddress.street
        a.street2.should.equal userAddress.street2
        a.city.should.equal userAddress.city
        a.state.should.equal userAddress.state
        a.zip.should.equal userAddress.zip

  describe 'a not logged in user logs in and comes back to the store and cart', ->
    before ->
      page.clearCookies()
      .then page.clearLocalStorage
      .then -> storeProductPage.visit 'store_1', 'name_1'
      .then storeProductPage.purchaseItem
      .then storeCartPage.clickFinishOrder
      .then -> loginPage.loginWith user1
    it 'should take back to the shipping page', -> page.currentUrl().should.become "http://localhost:8000/#{store.slug}/finishOrder/shipping"
    it 'should show address', ->
      page.address().then (a) ->
        userAddress = user1.deliveryAddress
        a.street.should.equal userAddress.street
        a.street2.should.equal userAddress.street2
        a.city.should.equal userAddress.city
        a.state.should.equal userAddress.state
        a.zip.should.equal userAddress.zip

  describe 'store with only products without shipping', ->
    before ->
      page.clearLocalStorage()
      .then -> page.loginFor user1._id
      .then -> storeProductPage.visit productNoShipping.storeSlug, productNoShipping.slug
      .then storeProductPage.purchaseItem
      .then storeCartPage.clickFinishOrder
    it 'should take directly to payment page', -> page.currentUrl().should.become "http://localhost:8000/#{productNoShipping.storeSlug}/finishOrder/payment"
