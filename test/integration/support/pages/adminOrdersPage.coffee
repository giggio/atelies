Page          = require './seleniumPage'

module.exports = class AccountOrdersPage extends Page
  url: 'admin/orders'
  orders: (cb) ->
    orders = []
    getData = []
    @findElementsIn '#orders tbody', 'tr'
    .then (els) =>
      for el in els
        do (el) =>
          order = {}
          orders.push order
          getData.push => @getAttributeIn(el, "._id", 'data-id').then (t) => order._id = t
          getData.push => @getTextIn(el, ".orderDate").then (t) => order.orderDate = t
          getData.push => @getTextIn(el, ".numberOfItems").then (t) => order.numberOfItems = parseInt t
          getData.push => @getTextIn(el, ".totalSaleAmount").then (t) => order.totalSaleAmount = t
          getData.push => @getTextIn(el, ".storeLink").then (t) => order.storeName = t
          getData.push => @getAttributeIn(el, ".orderLink", 'href').then (t) => order.orderLink = t
          getData.push => @getAttributeIn(el, ".storeLink", 'href').then (t) => order.storeLink = t
      @parallel getData
    .then -> orders
