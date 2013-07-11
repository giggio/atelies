Page          = require './seleniumPage'

module.exports = class StoreHomePage extends Page
  visit: (storeSlug, cb) => super storeSlug, cb
  products: @::findElements.partial '.storeContainer #products .product'
  notExistentText: @::getText.partial "#notExistent"
  searchProductsText: @::type.partial "#productSearchTerm"
  clickDoSearchProducts: @::pressButton.partial "#doSearchProduct"
  searchProductsLength: (cb) -> @findElements '#productsSearchResults .product', (els) -> cb els.length
  productLink: (_id, cb) -> @getAttribute "#product#{_id} .link", 'href', cb
