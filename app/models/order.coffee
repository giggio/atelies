mongoose  = require 'mongoose'
_         = require 'underscore'
Postman   = require './postman'
postman   = new Postman()
async     = require 'async'

orderSchema = new mongoose.Schema
  store:                      type: mongoose.Schema.Types.ObjectId, ref: 'store'
  items: [
    product:                  type: mongoose.Schema.Types.ObjectId, ref: 'product'
    name:                     type: String, required: true
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
    street:                   type: String, required: true
    street2:                  String
    city:                     type: String, required: true
    state:                    type: String, required: true
    zip:                      type: String, required: true
  paymentType:                type: String, required: true
  evaluation:                 type: mongoose.Schema.Types.ObjectId, ref: 'storeevaluation'

orderSchema.methods.addEvaluation = (evaluation, cb) ->
  evaluation.order = @
  evaluation.store = @store
  StoreEvaluation.create evaluation, (err, evaluation) =>
    return cb err, evaluation if err?
    @evaluation = evaluation
    Store.findById @store, (err, store) ->
      return cb err if err?
      store.evaluationAdded evaluation
      cb null, evaluation, store
orderSchema.methods.sendMailAfterEvaluation = (cb) ->
  @populate 'evaluation store', (err) =>
    return cb err if err?
    User.findAdminsFor @store._id, (err, users) =>
      return cb err if err?
      sendMailActions =
        for user in users
          do (user) =>
            body = "<html>
              <h1>Olá #{user.name},</h1>
              <h2>Sua loja recebeu uma avaliação</h2>
              <div>
                O cliente <a href=\"mailto:#{@evaluation.userEmail}\">#{@evaluation.userName}</a> fez uma
                avaliação de #{@evaluation.rating} estrelas, com o comentário '#{@evaluation.body}'.
              </div>
              <div>Você pode vê-lo <a href=\"https://www.atelies.com.br/#{@store.slug}#evaluations\">aqui</a>.</div>
              </html>"
            (cb) => postman.sendFromContact user, "Ateliês: A loja #{@store.name} recebeu uma avaliação", body, cb
      async.parallel sendMailActions, cb
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
  paymentType: @paymentType
orderSchema.methods.sendMailAfterPurchase = (cb) ->
  @populate 'store customer', =>

    clientMail = (cb)->
      body = "<html>
        <h1>#{@store.name}</h1>
        <h2>Recebemos seu pedido</h2>
        <div>Você será avisado assim que ele for liberado.</div>
        <div>Total da venda: R$ #{@totalSaleAmount}</div>
        <div>
          Não deixe de avaliar o vendedor e sua loja quando receber seu pedido. Você pode fazer isso
          clicando em 'Pedidos realizados' no menu, ou 'Ver pedidos' na <a href='https://www.atelies.com.br/account'>página da sua conta</a>.
        </div>
        <div>
          Você pode ver o seu pedido e também avaliá-lo clicando <a href='https://www.atelies.com.br/account#orders/#{@_id.toString()}'>aqui</a>.
        </div>
        <div>&nbsp;</div>
        <div>
          Obrigado!
        </div>
        <div>
          #{@store.name}
        </div>
        </html>"
      postman.send @store, @customer, "Pedido realizado", body, cb

    storeMail = (cb)->
      body = "<html>
        <h1>#{@store.name}</h1>
        <h2>Um pedido foi realizado</h2>
        <div>Total da venda: R$ #{@totalSaleAmount}</div>
        <div>
          Obrigado!
        </div>
        <div>
          #{@store.name}
        </div>
        </html>"
      postman.send @customer, @store, "Novo Pedido", body, cb

    async.parallel [clientMail, storeMail], cb

module.exports = Order = mongoose.model 'order', orderSchema

Order.create = (user, store, items, shippingCost, paymentType, cb) ->
  order = new Order customer:user, store:store, shippingCost: shippingCost
  for i in items
    item = product: i.product, price: i.product.price, quantity: i.quantity, totalPrice: i.product.price * i.quantity, name: i.product.name
    order.items.push item
  order.totalProductsPrice = _.chain(order.items).map((i)->i.totalPrice).reduce(((p, i) -> p+i), 0).value()
  order.totalSaleAmount = order.totalProductsPrice + order.shippingCost
  order.deliveryAddress = user.deliveryAddress
  order.paymentType = paymentType
  order.validate (err) ->
    cb err, order
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
Order.getSimpleByStores = (stores, cb) ->
  Order.find(store: $in: stores).populate('store', 'name slug').exec (err, orders) ->
    cb err, null if err?
    simpleOrders = _.map orders, (o)->
      _id: o._id.toString()
      storeName: o.store.name
      storeSlug: o.store.slug
      totalSaleAmount: o.totalSaleAmount
      orderDate: o.orderDate
      numberOfItems: o.items.length
    cb null, simpleOrders

Order.findSimpleWithItemsBySellerAndId = (user, _id, cb) ->
  Order.findById(_id)
  .populate('items.product', '_id name slug picture')
  .populate('customer', 'name email phoneNumber')
  .populate('store', 'name slug').exec (err, order) ->
    cb err, null if err?
    return cb null, null unless user.hasStore order.store
    simpleOrder =
      _id: order._id.toString()
      storeName: order.store.name
      storeSlug: order.store.slug
      totalSaleAmount: order.totalSaleAmount
      totalProductsPrice: order.totalProductsPrice
      shippingCost: order.shippingCost
      orderDate: order.orderDate
      numberOfItems: order.items.length
      deliveryAddress: order.deliveryAddress
      customer:
        name: order.customer.name
        email: order.customer.email
        phoneNumber: order.customer.phoneNumber
    simpleOrder.items = _.map order.items, (i) ->
      _id: i.product._id
      slug: i.product.slug
      name: i.product.name
      picture: i.product.picture
      price: i.price
      quantity: i.quantity
      totalPrice: i.totalPrice
    cb null, simpleOrder
Order.getSimpleWithItemsByUserAndId = (user, _id, cb) ->
  Order.findById(_id).populate('items.product', '_id name slug picture').populate('evaluation').exec (err, order) ->
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
    if order.evaluation?
      simpleOrder.evaluation =
        rating: order.evaluation.rating
        body: order.evaluation.body
    cb null, simpleOrder

StoreEvaluation = require './storeEvaluation'
Store = require './store'
User = require './user'
