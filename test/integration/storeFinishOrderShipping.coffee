require './support/_specHelper'
Store                           = require '../../app/models/store'
Product                         = require '../../app/models/product'
StoreFinishOrderShippingPage    = require './support/pages/storeFinishOrderShippingPage'
page                            = new StoreFinishOrderShippingPage()
StoreCartPage                   = require './support/pages/storeCartPage'
storeCartPage                   = new StoreCartPage page
StoreProductPage                = require './support/pages/storeProductPage'
storeProductPage                = new StoreProductPage page

describe 'Store Finish Order: Shipping', ->
  store = product1 = product2 = store2 = user1 = userIncompleteAddress = null
  after (done) -> page.closeBrowser done
  before (done) =>
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
      whenServerLoaded done

  describe 'logged in user with full address', ->
    before (done) ->
      page.clearCookies ->
        page.clearLocalStorage ->
          page.loginFor user1._id, ->
            storeProductPage.visit 'store_1', 'name_1', ->
              storeProductPage.purchaseItem ->
                storeProductPage.visit 'store_1', 'name_2', ->
                  storeProductPage.purchaseItem ->
                    storeCartPage.clickFinishOrder done
    it 'should show address', (done) ->
      page.address (a) ->
        userAddress = user1.deliveryAddress
        a.street.should.equal userAddress.street
        a.street2.should.equal userAddress.street2
        a.city.should.equal userAddress.city
        a.state.should.equal userAddress.state
        done()

  describe 'not logged in user', (done) ->
    before (done) ->
      page.clearCookies ->
        page.clearLocalStorage ->
          storeProductPage.visit 'store_1', 'name_1', ->
            storeProductPage.purchaseItem ->
              storeProductPage.visit 'store_1', 'name_2', ->
                storeProductPage.purchaseItem ->
                  storeCartPage.clickFinishOrder done
    it 'should be redirected to login', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/account/login?redirectTo=/#{store.slug}#finishOrder/shipping"
        done()

  describe 'logged in user with incomplete address', ->
    before (done) ->
      page.clearCookies ->
        page.clearLocalStorage ->
          page.loginFor userIncompleteAddress._id, ->
            storeProductPage.visit 'store_1', 'name_1', ->
              storeProductPage.purchaseItem ->
                storeProductPage.visit 'store_1', 'name_2', ->
                  storeProductPage.purchaseItem ->
                    storeCartPage.clickFinishOrder done
    it 'should redirect to update profile page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/#{store.slug}#finishOrder/updateProfile"
        done()
