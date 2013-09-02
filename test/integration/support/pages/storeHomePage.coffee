Page          = require './seleniumPage'
async         = require 'async'

module.exports = class StoreHomePage extends Page
  visit: (storeSlug, cb) => super storeSlug, cb
  products: @::findElements.partial '.storeContainer #products .product'
  notExistentText: @::getText.partial "#notExistent"
  searchProductsText: @::type.partial "#productSearchTerm"
  clickDoSearchProducts: @::pressButton.partial "#doSearchProduct"
  searchProductsLength: (cb) -> @findElements '#productsSearchResults .product', (els) -> cb els.length
  productLink: (_id, cb) -> @getAttribute "#product#{_id} .link", 'href', cb
  evaluation: (cb) ->
    @findElement('#evaluation').then (el) =>
      getEvaluationActions =
        ratingStars: (cb) => @getAttributeIn el, "#ratingStars", "data-average", (t) -> cb null, parseFloat t
        ratingDescription: (cb) => @getTextIn el, "#ratingDescription", (t) -> cb null, t
      async.parallel getEvaluationActions, (err, ev) -> cb ev
