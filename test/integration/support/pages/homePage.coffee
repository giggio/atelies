Page          = require './seleniumPage'
async         = require 'async'
webdriver       = require 'selenium-webdriver'
Q               = require 'q'

module.exports = class HomePage extends Page
  url: ''
  clickSearchStores: -> @waitForReady().then => @pressButton ".searchStores"
  searchStoresText: (text) ->
    @waitForSelectorClickable '#storeSearchTerm'
    .then => @type "#storeSearchTerm", text
  clickDoSearchStores: @::pressButton.partial "#doSearch"
  searchProductsText: @::type.partial "#productSearchTerm"
  clickDoSearchProducts: @::pressButton.partial "#doSearchProduct"
  storesWithoutFlyersLength: -> @findElements('#storesWithoutFlyer .storeWithoutFlyer').then @captureAttribute 'length'
  storesLength: -> @findElements('#stores .store').then @captureAttribute 'length'
  storeLink: (_id) -> @getAttribute "#store#{_id} .link", 'href'
  searchProductsLength: -> @findElements('#productsSearchResults .product').then @captureAttribute 'length'
  productLink: (_id) -> @getAttribute "#product#{_id} .link", 'href'
  productsLength: -> @findElements('#products .product').then (els) -> els.length
  product: (_id) ->
    product = {}
    Q.nfcall async.parallel, [
      (cb) => @getAttribute("#product#{_id}", "data-id").then (t) -> product._id = t;cb()
      (cb) => @getInnerHtml("#product#{_id} .storeName").then (t) -> product.storeName = t;cb()
      (cb) => @getAttribute("#product#{_id}_picture img", "src").then (t) -> product.picture = t;cb()
      (cb) => @getAttribute("#product#{_id}_picture", "href").then (t) -> product.slug = t;cb()
    ]
    .then -> product
  storesIds: @::getAttributeInElements.partial '#stores .store', "data-id"
