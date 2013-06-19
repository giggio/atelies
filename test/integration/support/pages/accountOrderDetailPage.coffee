Page          = require './seleniumPage'

module.exports = class AccountOrdersPage extends Page
  visit: (_id, cb) -> super "account#orders/#{_id}", cb
  order: (cb) ->
    items = []
    order = deliveryAddress:{}, items: items
    getData = []
    getData.push => @getAttribute "#_id", 'data-id', (t) => order._id = t
    getData.push => @getText "#orderDate", (t) -> order.orderDate = t
    getData.push => @getText "#storeLink", (t) -> order.storeName = t
    getData.push => @getAttribute "#storeLink", 'href', (t) => order.storeUrl = t
    getData.push => @getText "#numberOfItems", (t) -> order.numberOfItems = parseInt t
    getData.push => @getText "#shippingCost", (t) -> order.shippingCost = t
    getData.push => @getText "#totalProductsPrice", (t) -> order.totalProductsPrice = t
    getData.push => @getText "#totalSaleAmount", (t) -> order.totalSaleAmount = t
    getData.push => @getText "#street", (t) -> order.deliveryAddress.street = t
    getData.push => @getText "#street2", (t) -> order.deliveryAddress.street2 = t
    getData.push => @getText "#city", (t) -> order.deliveryAddress.city = t
    getData.push => @getText "#state", (t) -> order.deliveryAddress.state = t
    getData.push => @getText "#zip", (t) -> order.deliveryAddress.zip = t
    @findElementsIn '#items tbody', 'tr', (els) =>
      for el in els
        do (el) =>
          item = {}
          items.push item
          getData.push => @getAttribute el, 'data-id', (t) => item._id = t
          getData.push => @getTextIn el, ".url", (t) => item.name = t
          getData.push => @getTextIn el, ".price", (t) => item.price = t
          getData.push => @getTextIn el, ".quantity", (t) => item.quantity = parseInt t
          getData.push => @getTextIn el, ".totalPrice", (t) => item.totalPrice = t
          getData.push => @getAttributeIn el, ".url", 'href', (t) => item.url = t
          getData.push => @getAttributeIn el, ".picture", 'src', (t) => item.picture = t
      @parallel getData, -> cb(order)
      undefined
