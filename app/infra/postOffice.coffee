_               = require 'underscore'
Product         = require '../models/product'
correios        = require 'correios'
Q               = require 'q'

module.exports = class PostOffice
  calculateShipping: (storeZip, items, userZip) ->
    ids = _.pluck items, '_id'
    pac = type: 'pac', name: 'PAC', cost: 0, days: 0
    sedex = type: 'sedex', name: 'Sedex', cost: 0, days: 0
    shippingOptions = [ pac, sedex ]
    Product.getShippingWeightAndDimensions ids
    .then (products) ->
      getShippingPricesFor = (service, shipping, quantity) ->
        deliverySpecs = serviceType: service.type, from: storeZip, to: userZip, weight: shipping.weight, height: shipping.dimensions.height, width: shipping.dimensions.width, length: shipping.dimensions.depth
        Q.ninvoke correios, 'getPrice', deliverySpecs
        .then (delivery) ->
          #console.log "got price for #{service.type} with specs #{JSON.stringify deliverySpecs}, with response #{JSON.stringify delivery}"
          service.cost += delivery.GrandTotal * quantity if shipping.charge
          service.days = delivery.estimatedDelivery if delivery.estimatedDelivery > service.days
      getShippingPrices = []
      for product in products when product.hasShippingInfo()
        do (product) ->
          quantity = parseInt _.findWhere(items, _id: product._id.toString()).quantity
          getShippingPrices.push getShippingPricesFor pac, product.shipping, quantity
          getShippingPrices.push getShippingPricesFor sedex, product.shipping, quantity
      Q.all getShippingPrices
    .then -> shippingOptions
    .catch (err) -> throw new Error "Erro ao obter custo de postagem.\n#{err}"
