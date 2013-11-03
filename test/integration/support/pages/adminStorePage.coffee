Page = require './seleniumPage'

module.exports = class AdminHomePage extends Page
  visit: (storeSlug, cb) => super "admin/store/#{storeSlug}", cb
  storeName: @::getText.partial "#name"
  rows: @::findElements.partial '#products .product'
  productsQuantity: (cb) => @rows (rows) -> cb rows.length
  products: (cb) =>
    products = []
    getData = []
    @findElementsIn '#products', '.product', (els) =>
      for el in els
        do (el) =>
          product = {}
          products.push product
          getData.push => @getAttribute el, 'data-id', (t) => product.id = t
          getData.push => @getAttributeIn el, "img", 'src', (t) => product.picture = t
          getData.push => @getTextIn el, ".name", (t) => product.name = t
          getData.push => @getAttributeIn el, ".link", "href", (t) => product.manageLink = t
      @parallel getData, -> cb(products)
      undefined
  createProductLink: @::getAttribute.partial '#createProduct', 'href'
