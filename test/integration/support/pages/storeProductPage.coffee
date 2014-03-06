Page          = require './seleniumPage'
async         = require 'async'
Q             = require 'q'

module.exports = class StoreProductPage extends Page
  visit: (storeSlug, productSlug) -> super "#{storeSlug}/#{productSlug}"
  purchaseItem: -> @pressButton "#purchaseItem"
  product: ->
    product = {}
    @parallel [
      => @getText("#product #name").then (text) -> product.name = text
      => @getText("#product #price").then (text) -> product.price = text
      => @getTexts("#product .tag").then (texts) -> product.tags = texts
      => @getText("#product #description").then (text) -> product.description = text
      => @getText("#product #dimensions #height").then (text) -> product.height = text
      => @getText("#product #dimensions #width").then (text) -> product.width = text
      => @getText("#product #dimensions #depth").then (text) -> product.depth = text
      => @getText("#product #weight").then (text) -> product.weight = text
      => @getText("#product #inventory").then (text) -> product.inventory = text
      => @getText("#storeName").then (text) -> product.storeName = text
      => @getText("#storePhoneNumber").then (text) -> product.storePhoneNumber = text
      => @getText("#storeCity").then (text) -> product.storeCity = text
      => @getText("#storeState").then (text) -> product.storeState = text
      => @getText("#storeOtherUrl").then (text) -> product.storeOtherUrl = text
      => @getSrc("#storeBanner").then (text) -> product.banner = text
      => @getSrc("#product #picture").then (text) -> product.picture = text
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
                userName: (cb) => @getTextIn(el, ".userName").then (t) -> cb null, t
                userPicture: (cb) => @getSrcIn(el, ".userPicture").then (t) -> cb null, t
                body: (cb) => @getTextIn(el, ".body").then (t) -> cb null, t
                date: (cb) => @getTextIn(el, ".date").then (t) -> cb null, t
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
