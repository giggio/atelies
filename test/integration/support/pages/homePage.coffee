Page          = require './seleniumPage'

module.exports = class HomePage extends Page
  url: ''
  clickSearchStores: @::pressButton.partial ".searchStores"
  searchStoresText: @::type.partial "#storeSearchTerm"
  clickDoSearchStores: @::pressButton.partial "#doSearch"
  searchProductsText: @::type.partial "#productSearchTerm"
  clickDoSearchProducts: @::pressButton.partial "#doSearchProduct"
  storesLength: (cb) -> @findElements '#stores .store', (els) -> cb els.length
  storeLink: (_id, cb) -> @getAttribute "#store#{_id} .link", 'href', cb
  productsLength: (cb) -> @findElements '#productsSearchResults .product', (els) -> cb els.length
  productLink: (_id, cb) -> @getAttribute "#product#{_id} .link", 'href', cb
