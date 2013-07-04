require './support/_specHelper'
Product                         = require '../../app/models/product'
Order                           = require '../../app/models/order'
StoreFinishOrderPaymentPage     = require './support/pages/storeFinishOrderPaymentPage'
StoreFinishOrderShippingPage    = require './support/pages/storeFinishOrderShippingPage'
StoreCartPage                   = require './support/pages/storeCartPage'
StoreProductPage                = require './support/pages/storeProductPage'

describe 'Store Finish Order: Payment', ->
  page = storeFinishOrderShippingPage = storeCartPage = storeProductPage = store = product1 = product2 = product3 = store2 = user1 = p1Inventory = p2Inventory = null
  after (done) -> page.closeBrowser done
  before (done) =>
    page = new StoreFinishOrderPaymentPage
    storeFinishOrderShippingPage = new StoreFinishOrderShippingPage page
    storeCartPage = new StoreCartPage page
    storeProductPage = new StoreProductPage page
    whenServerLoaded done

  describe 'payment info', ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        store = generator.store.a()
        store.save()
        product1 = generator.product.a()
        product1.save()
        p1Inventory = product1.inventory
        product2 = generator.product.b()
        product2.save()
        p2Inventory = product2.inventory
        user1 = generator.user.d()
        user1.save()
        page.clearCookies ->
          page.clearLocalStorage ->
            page.loginFor user1._id, ->
              storeProductPage.visit 'store_1', 'name_1', ->
                storeProductPage.purchaseItem ->
                  storeProductPage.visit 'store_1', 'name_2', ->
                    storeProductPage.purchaseItem ->
                      storeCartPage.clickFinishOrder ->
                        storeFinishOrderShippingPage.clickSedexOption ->
                          storeFinishOrderShippingPage.clickContinue done
    it 'should show options for payment type with PagSeguro already selected', (done) ->
        done()
    it 'should be at payment page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/#{store.slug}#finishOrder/payment"
        done()
