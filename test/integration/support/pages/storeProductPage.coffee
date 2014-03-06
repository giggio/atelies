Page          = require './seleniumPage'
async         = require 'async'
Q             = require 'q'

module.exports = class StoreProductPage extends Page
  visit: (storeSlug, productSlug) -> super "#{storeSlug}/#{productSlug}"
  purchaseItem: -> @pressButton "#purchaseItem"
  product: ->
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
    ]
    .then -> product
  storeNameHeader: @::getText.partial "#storeNameHeader"
  storeNameHeaderExists: @::hasElement.partial '#storeNameHeader'
  storeBannerExists: @::hasElement.partial '#storeBanner'
  purchaseItemButtonEnabled: @::getIsEnabled.partial "#purchaseItem"
  comments: ->
    @findElementsIn('#comments', '.comment').then (els) =>
      getCommentsAction =
        for el in els
          do (el) =>
            (getCommentCb) =>
              getCommentActions =
                userName: (cb) => @getTextIn el, ".userName", (t) -> cb null, t
                userPicture: (cb) => @getSrcIn el, ".userPicture", (t) -> cb null, t
                body: (cb) => @getTextIn el, ".body", (t) -> cb null, t
                date: (cb) => @getTextIn el, ".date", (t) -> cb null, t
              async.parallel getCommentActions, getCommentCb
      Q.nfcall async.parallel, getCommentsAction
  writeComment: (comm) ->
    @type "#newCommentBody", comm
    .then => @pressButtonAndWait "#createComment"
    .then @closeDialog
  newCommentBodyText: @::getValue.partial "#newCommentBody"
  commentBodyIsVisible: @::hasElement.partial "#newCommentBody"
  commentButtonIsVisible: @::hasElement.partial "#createComment"
  mustLoginToCommentMessageIsVisible: @::isVisible.partial "#mustLoginToCommentMessage"
