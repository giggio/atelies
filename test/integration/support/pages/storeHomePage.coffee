Page          = require './seleniumPage'
Q             = require 'q'

module.exports = class StoreHomePage extends Page
  visit: (storeSlug) -> super storeSlug
  products: @::findElements.partial '.storeContainer #products .product'
  notExistentText: @::getText.partial "#notExistent"
  searchProductsText: @::type.partial "#productSearchTerm"
  clickDoSearchProducts: @::pressButton.partial "#doSearchProduct"
  searchProductsLength: -> @findElements('#productsSearchResults .product').then captureAttribute "length"
  productLink: (_id) -> @getAttribute "#product#{_id} .link", 'href'
  evaluation: ->
    @findElement('#evaluation')
    .then (el) =>
      @resolveObj
        ratingStars: @getAttributeIn(el, "#ratingStars", "data-average").then (t) -> parseFloat t
        ratingDescription: @getTextIn el, "#ratingDescription"
