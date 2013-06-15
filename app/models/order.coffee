mongoose  = require 'mongoose'
_         = require 'underscore'

orderSchema = new mongoose.Schema
  store:                      type: mongoose.Schema.Types.ObjectId, ref: 'store'
  items: [
    product:                  type: mongoose.Schema.Types.ObjectId, ref: 'product'
    price:                    type: Number, required: true
    quantity:                 type: Number, required: true
    totalPrice:               type: Number, required: true
  ]
  totalProductsPrice:         type: Number, required: true
  shippingCost:               type: Number, required: true
  totalSaleAmount:            type: Number, required: true
  orderDate:                  type: Date, required: true, default: Date.now
  customer:                   type: mongoose.Schema.Types.ObjectId, ref: 'user'
  deliveryAddress:
    street:         String
    street2:        String
    city:           String
    state:          String
    zip:            String

orderSchema.methods.toSimpleOrder = ->
  items = _.map @items, (i) ->
    _id: i.product.toString()
    price: i.price,
    quantity: i.quantity
    totalPrice: i.totalPrice
  _id: @_id
  totalProductsPrice: @totalProductsPrice
  shippingCost: @shippingCost
  totalSaleAmount: @totalSaleAmount
  orderDate: @orderDate
  items: items
Order = mongoose.model 'order', orderSchema
Order.create = (user, store, items, shippingCost, cb) ->
  order = new Order customer:user, store:store, shippingCost: shippingCost
  for i in items
    order.items.push product: i.product, price: i.product.price, quantity: i.quantity, totalPrice: i.product.price * i.quantity
  order.totalProductsPrice = _.chain(order.items).map((i)->i.totalPrice).reduce(((p, i) -> p+i), 0).value()
  order.totalSaleAmount = order.totalProductsPrice + order.shippingCost
  order.deliveryAddress = user.deliveryAddress
  process.nextTick -> cb order

module.exports = Order
