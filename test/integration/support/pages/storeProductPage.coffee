Page          = require './seleniumPage'

module.exports = class StoreProductPage extends Page
  visit: (storeSlug, productSlug, cb) => super "#{storeSlug}##{productSlug}", cb
  purchaseItem: (cb) => @pressButton "#purchaseItem", cb
  product: (cb) ->
    product = {}
    @parallel [
      => @getText "#product #name", (text) -> product.name = text
      => @getText "#product #price", (text) -> product.price = text
      => @getTexts "#product .tag", (texts) -> product.tags = texts
      => @getText "#product #description", (text) -> product.description = text
      => @getText "#product #dimensions #height", (text) -> product.height = text
      => @getText "#product #dimensions #width", (text) -> product.width = text
      => @getText "#product #dimensions #depth", (text) -> product.depth = text
      => @getText "#product #weight", (text) -> product.weight = text
      => @getText "#product #inventory", (text) -> product.inventory = text
      => @getText "#storeName", (text) -> product.storeName = text
      => @getText "#storePhoneNumber", (text) -> product.storePhoneNumber = text
      => @getText "#storeCity", (text) -> product.storeCity = text
      => @getText "#storeState", (text) -> product.storeState = text
      => @getText "#storeOtherUrl", (text) -> product.storeOtherUrl = text
      => @getSrc "#storeBanner", (text) -> product.banner = text
      => @getSrc "#product #picture", (text) -> product.picture = text
    ], (-> cb(product))
  storeNameHeader: @::getText.partial "#storeNameHeader"
  storeNameHeaderExists: @::hasElement.partial '#storeNameHeader'
  storeBannerExists: @::hasElement.partial '#storeBanner'
