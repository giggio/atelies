mongoose  = require 'mongoose'
_         = require 'underscore'
Postman   = require './postman'
postman   = new Postman()
Q         = require 'q'

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
  state:                      type: String, required: true, default: 'ordered', enum: {values: ['ordered', 'delivered', 'paymentDone', 'inProduction', 'posted', 'returned'], message: 'Valor incorreto passado para o estado do pedido.'}
  paymentGatewayInfo:
    paypal:
      id:                     type: String
      state:                  type: String

OrderStatus =
  ordered: 'Pedido realizado'
  delivered: 'Entregue'
  paymentDone: 'Pagamento realizado'
  inProduction: 'Em produção'
  posted: 'Despachado'
  returned: 'Devolvido'

orderSchema.methods.updatePaypalInfo = (info) -> @paymentGatewayInfo.paypal = info
orderSchema.methods.addEvaluation = (evaluation) ->
  evaluation.order = @
  evaluation.store = @store
  StoreEvaluation.create evaluation
  .then (ev) =>
    @evaluation = ev
    [ev, Q.ninvoke Store, "findById", @store]
  .spread (ev, store) =>
    store.evaluationAdded ev
    evaluation: ev, store: store, order: @
orderSchema.methods.sendMailAfterEvaluation = ->
  Q.ninvoke @, 'populate', 'evaluation store'
  .then => User.findAdminsFor @store._id
  .then (users) =>
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
            <div>Você pode vê-lo <a href='#{CONFIG.secureUrl}/#{@store.slug}/evaluations'>aqui</a>.</div>
            </html>"
          postman.sendFromContact user, "Ateliês: A loja #{@store.name} recebeu uma avaliação", body
    Q.allSettled sendMailActions
orderSchema.methods.sendMailAfterStateChange = ->
  Q.ninvoke @, 'populate', 'store customer'
  .then (order) ->
    data= new Date()
    data= "#{data.getDate()}/#{data.getMonth()+1}/#{data.getFullYear()}"
    body = "<html>
      <h1>#{order.store.name}</h1>
      <h2>Seu pedido foi alterado</h2>
      <div>
        O seu pedido foi marcado pelo vendedor como #{OrderStatus[order.state]}.<br />
        #{if order.state is 'delivered' then "Não deixe de avaliar sua compra e o vendedor. Você pode fazer isso clicando em 'Pedidos realizados' no menu, ou 'Ver pedidos' na <a href='#{CONFIG.secureUrl}/account'>página da sua conta</a>." else "" }
      </div>
      <div>
        Você pode ver o seu pedido e também avaliá-lo clicando <a href='#{CONFIG.secureUrl}/account/orders/#{order._id.toString()}'>aqui</a>.
      </div>
      <div>&nbsp;</div>
      <div>
        Obrigado!
      </div>
      <div>
        #{order.store.name}
      </div>
      <div>#{data}</div>
      </html>"
    postman.send order.store, order.customer, "Ateliês: Seu pedido na loja #{order.store.name} foi alterado", body
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

orderSchema.methods.sendMailAfterPurchase = ->
  Q.ninvoke @, 'populate', 'store customer'
  .then (order) =>
    dataPedido = new Date()
    dataPedido = "#{dataPedido.getDate()}/#{dataPedido.getMonth()+1}/#{dataPedido.getFullYear()}"
    body = "<html>
      <h1>#{order.store.name}</h1>
      <h2>Recebemos seu pedido</h2>
      <div>Você será avisado assim que ele for liberado.</div>
      <div>Total da venda: R$ #{order.totalSaleAmount}</div>
      <div>
        Não deixe de avaliar o vendedor e sua loja quando receber seu pedido. Você pode fazer isso
        clicando em 'Pedidos realizados' no menu, ou 'Ver pedidos' na <a href='#{CONFIG.secureUrl}/account'>página da sua conta</a>.
      </div>
      <div>
        Você pode ver o seu pedido e também avaliá-lo clicando <a href='#{CONFIG.secureUrl}/account/orders/#{order._id.toString()}'>aqui</a>.
      </div>
      <div>&nbsp;</div>
      <div>
        Obrigado!
      </div>
      <div>
        #{order.store.name}
      </div>
      </html>"
    clientMail = postman.send order.store, order.customer, "Pedido realizado", body
    body = "<html>
      <h2>Sua loja #{order.store.name} recebeu um novo pedido.</h2>
      <div></div>
      <div>Veja detalhes dessa venda no Ateliês <a href='#{CONFIG.secureUrl}/admin/orders/#{order._id.toString()}'>clicando aqui</a>.</div>
      <div>&nbsp;</div>
      <div>Cliente: <a href='mailto:#{order.customer.email}'>#{order.customer.name}</a></div>
      <div>Data: #{dataPedido}</div>
      <div>Total da venda: R$ #{order.totalSaleAmount}</div>
      <div>&nbsp;</div>
      <div>Obrigado!</div>
      <div>Equipe Ateliês</div>
      </html>"
    storeMail = postman.sendFromContact order.store, "Novo Pedido", body
    Q.allSettled [clientMail, storeMail]
    .then (mailResponses) => [@, mailResponses]

module.exports = Order = mongoose.model 'order', orderSchema

Order.removeByStore = (store) -> Q.ninvoke Order, "remove", store: store._id
Order.create = (user, store, items, shippingCost, paymentType) ->
  order = new Order customer:user, store:store, shippingCost: shippingCost
  for i in items
    item = product: i.product, price: i.product.price, quantity: i.quantity, totalPrice: i.product.price * i.quantity, name: i.product.name
    order.items.push item
  order.totalProductsPrice = _.chain(order.items).map((i)->i.totalPrice).reduce(((p, i) -> p+i), 0).value()
  order.totalSaleAmount = order.totalProductsPrice + order.shippingCost
  order.deliveryAddress = user.deliveryAddress
  order.paymentType = paymentType
  Q.ninvoke order, 'validate'
  .then -> order
Order.getSimpleByUser = (user) ->
  Q Order.find(customer: user).populate('store', 'name slug')
  .then (orders) ->
    simpleOrders = _.map orders, (o)->
      _id: o._id.toString()
      storeName: o.store.name
      storeSlug: o.store.slug
      totalSaleAmount: o.totalSaleAmount
      orderDate: o.orderDate
      numberOfItems: o.items.length
      state: o.state
    simpleOrders
Order.getSimpleByStores = (stores) ->
  Q Order.find(store: $in: stores).populate('store', 'name slug')
  .then (orders) ->
    simpleOrders = _.map orders, (o)->
      _id: o._id.toString()
      storeName: o.store.name
      storeSlug: o.store.slug
      totalSaleAmount: o.totalSaleAmount
      orderDate: o.orderDate
      numberOfItems: o.items.length
      state: o.state
    simpleOrders

Order.findSimpleWithItemsBySellerAndId = (user, _id) ->
  find = Order.findById(_id)
  .populate('items.product', '_id name slug picture')
  .populate('customer', 'name email phoneNumber')
  .populate('store', 'name slug')
  Q(find).then (order) ->
    return null unless user.hasStore order.store
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
      state: order.state
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
    simpleOrder
Order.getSimpleWithItemsByUserAndId = (user, _id) ->
  Q Order.findById(_id).populate('items.product', '_id name slug picture').populate('evaluation')
  .then (order) ->
    return null if order.customer.toString() isnt user._id.toString()
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
    simpleOrder

StoreEvaluation = require './storeEvaluation'
Store = require './store'
User = require './user'
