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
    item = product: i.product, price: i.product.price, quantity: i.quantity, totalPrice: i.product.price * i.quantity
    order.items.push item
  order.totalProductsPrice = _.chain(order.items).map((i)->i.totalPrice).reduce(((p, i) -> p+i), 0).value()
  order.totalSaleAmount = order.totalProductsPrice + order.shippingCost
  order.deliveryAddress = user.deliveryAddress
  process.nextTick -> cb order
Order.getSimpleByUser = (user, cb) ->
  Order.find(customer: user).populate('store', 'name slug').exec (err, orders) ->
    cb err, null if err?
    simpleOrders = _.map orders, (o)->
      _id: o._id.toString()
      storeName: o.store.name
      storeSlug: o.store.slug
      totalSaleAmount: o.totalSaleAmount
      orderDate: o.orderDate
      numberOfItems: o.items.length
    cb null, simpleOrders

Order.getSimpleWithItemsByUserAndId = (user, _id, cb) ->
  Order.findById(_id).populate('items.product', '_id name slug picture').exec (err, order) ->
    cb err, null if err?
    return cb null, null if order.customer.toString() isnt user._id.toString()
    simpleOrder =
      _id: order._id.toString()
      totalSaleAmount: order.totalSaleAmount
      totalProductsPrice: order.totalProductsPrice
      shippingCost: order.shippingCost
      orderDate: order.orderDate
      numberOfItems: order.items.length
      deliveryAddress: order.deliveryAddress
    simpleOrder.items = _.map order.items, (i) ->
      _id: i.product._id
      slug: i.product.slug
      name: i.product.name
      picture: i.product.picture
      price: i.price
      quantity: i.quantity
      totalPrice: i.totalPrice
    cb null, simpleOrder

module.exports = Order
