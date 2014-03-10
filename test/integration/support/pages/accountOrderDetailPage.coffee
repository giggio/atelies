Page          = require './seleniumPage'
webdriver     = require 'selenium-webdriver'
async         = require 'async'
Q             = require 'q'

module.exports = class AccountOrdersPage extends Page
  visit: (_id) -> super "account/orders/#{_id}"
  order: ->
    items = []
    order = deliveryAddress:{}, items: items
    getData = []
    getData.push => @getAttribute("#_id", 'data-id').then (t) -> order._id = t
    getData.push => @getText("#orderDate").then (t) -> order.orderDate = t
    getData.push => @getText("#storeLink").then (t) -> order.storeName = t
    getData.push => @getAttribute("#storeLink", 'href').then (t) -> order.storeUrl = t
    getData.push => @getText("#numberOfItems").then (t) -> order.numberOfItems = parseInt t
    getData.push => @getText("#shippingCost").then (t) -> order.shippingCost = t
    getData.push => @getText("#totalProductsPrice").then (t) -> order.totalProductsPrice = t
    getData.push => @getText("#totalSaleAmount").then (t) -> order.totalSaleAmount = t
    getData.push => @getText("#street").then (t) -> order.deliveryAddress.street = t
    getData.push => @getText("#street2").then (t) -> order.deliveryAddress.street2 = t
    getData.push => @getText("#city").then (t) -> order.deliveryAddress.city = t
    getData.push => @getText("#state").then (t) -> order.deliveryAddress.state = t
    getData.push => @getText("#zip").then (t) -> order.deliveryAddress.zip = t
    @findElementsIn '#items tbody', 'tr'
    .then (els) =>
      for el in els
        do (el) =>
          item = {}
          items.push item
          getData.push => @getAttribute(el, 'data-id').then (t) -> item._id = t
          getData.push => @getTextIn(el, ".url").then (t) -> item.name = t
          getData.push => @getTextIn(el, ".price").then (t) -> item.price = t
          getData.push => @getTextIn(el, ".quantity").then (t) -> item.quantity = parseInt t
          getData.push => @getTextIn(el, ".totalPrice").then (t) -> item.totalPrice = t
          getData.push => @getAttributeIn(el, ".url", 'href').then (t) -> item.url = t
          getData.push => @getAttributeIn(el, ".picture", 'src').then (t) -> item.picture = t
    .then => @parallel getData
    .then -> order
  newEvaluationVisible: @::hasElementAndIsVisible.partial '#newEvaluation'
  evaluateOrderWith: (opt) ->
    @type "#newEvaluationBody", opt.body
    .then => @findElement("#newRatingStars .jStar")
    .then (starEl) =>
      action = new webdriver.ActionSequence @driver
      action.mouseMove(starEl, {x:23*opt.rating, y:0})
        .click()
        .perform()
    .then => @pressButtonAndWait "#createEvaluation"
  existingEvaluation: -> @getAttribute("#evaluation #ratingStars", "data-average").then (t) -> parseFloat t
