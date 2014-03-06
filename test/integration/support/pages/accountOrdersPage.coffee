Page          = require './seleniumPage'

module.exports = class AccountOrdersPage extends Page
  url: 'account/orders'
  orders: ->
    orders = []
    getData = []
    @findElementsIn '#orders tbody', 'tr'
    .then (els) =>
      for el in els
        do (el) =>
          order = {}
          orders.push order
          getData.push => @getAttributeIn el, "._id", 'data-id', (t) => order._id = t
          getData.push => @getTextIn el, ".orderDate", (t) => order.orderDate = t
          getData.push => @getTextIn el, ".numberOfItems", (t) => order.numberOfItems = parseInt t
          getData.push => @getTextIn el, ".totalSaleAmount", (t) => order.totalSaleAmount = t
          getData.push => @getTextIn el, ".storeLink", (t) => order.storeName = t
          getData.push => @getAttributeIn el, ".orderLink", 'href', (t) => order.orderLink = t
          getData.push => @getAttributeIn el, ".storeLink", 'href', (t) => order.storeLink = t
      @parallel getData
    .then -> orders
