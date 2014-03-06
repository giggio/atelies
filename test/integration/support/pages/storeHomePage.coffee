Page          = require './seleniumPage'
async         = require 'async'
Q             = require 'q'

module.exports = class StoreHomePage extends Page
  visit: (storeSlug) => super storeSlug
  products: @::findElements.partial '.storeContainer #products .product'
  notExistentText: @::getText.partial "#notExistent"
  searchProductsText: @::type.partial "#productSearchTerm"
  clickDoSearchProducts: @::pressButton.partial "#doSearchProduct"
  searchProductsLength: -> @findElements('#productsSearchResults .product').then captureAttribute "length"
  productLink: (_id) -> @getAttribute "#product#{_id} .link", 'href'
  evaluation: ->
    @findElement('#evaluation').then (el) => Q.nfcall async.parallel,
      ratingStars: (cb) => @getAttributeIn el, "#ratingStars", "data-average", (t) -> cb null, parseFloat t
      ratingDescription: (cb) => @getTextIn el, "#ratingDescription", (t) -> cb null, t
