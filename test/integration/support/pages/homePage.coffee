Page          = require './seleniumPage'
async         = require 'async'

module.exports = class HomePage extends Page
  url: ''
  clickSearchStores: @::pressButton.partial ".searchStores"
  searchStoresText: (text, cb) ->
    @waitForSelectorClickable '#storeSearchTerm', =>
      @type "#storeSearchTerm", text, cb
  clickDoSearchStores: @::pressButton.partial "#doSearch"
  searchProductsText: @::type.partial "#productSearchTerm"
  clickDoSearchProducts: @::pressButton.partial "#doSearchProduct"
  storesWithoutFlyersLength: (cb) -> @findElements '#storesWithoutFlyer .storeWithoutFlyer', (els) -> cb els.length
  storesLength: (cb) -> @findElements '#stores .store', (els) -> cb els.length
  storeLink: (_id, cb) -> @getAttribute "#store#{_id} .link", 'href', cb
  searchProductsLength: (cb) -> @findElements '#productsSearchResults .product', (els) -> cb els.length
  productLink: (_id, cb) -> @getAttribute "#product#{_id} .link", 'href', cb
  productsLength: (cb) -> @findElements '#products .product', (els) -> cb els.length
  product: (_id, cb) ->
    product = {}
    actions = [
      (cb) => @getAttribute "#product#{_id}", "data-id", (t) -> product._id = t;cb()
      (cb) => @getInnerHtml "#product#{_id} .storeName", (t) -> product.storeName = t;cb()
      (cb) => @getAttribute "#product#{_id}_picture img", "src", (t) -> product.picture = t;cb()
      (cb) => @getAttribute "#product#{_id}_picture", "href", (t) -> product.slug = t;cb()
    ]
    async.parallel actions, ->
      cb product
  storesIds: @::getAttributeInElements.partial '#stores .store', "data-id"
