Page = require './seleniumPage'

module.exports = class AdminHomePage extends Page
  visit: (storeSlug) => super "admin/store/#{storeSlug}"
  storeName: @::getText.partial "#name"
  rows: @::findElements.partial '#products .product'
  productsQuantity: => @rows().then (rows) -> rows.length
  products: =>
    products = []
    getData = []
    @findElementsIn '#products', '.product', (els) =>
      for el in els
        do (el) =>
          product = {}
          products.push product
          getData.push => @getAttribute(el, 'data-id').then (t) => product.id = t
          getData.push => @getAttributeIn(el, "img", 'src').then (t) => product.picture = t
          getData.push => @getTextIn(el, ".name").then (t) => product.name = t
          getData.push => @getAttributeIn(el, ".link", "href").then (t) => product.manageLink = t
      @parallel getData
    .then -> products
  createProductLink: @::getAttribute.partial '#createProduct', 'href'
