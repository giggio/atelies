async           = require 'async'
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
    Q.nfcall Product.getShippingWeightAndDimensions, ids
    .then (products) ->
      getShippingPricesFor = (service, shipping, quantity) =>
        (cb) =>
          deliverySpecs = serviceType: service.type, from: storeZip, to: userZip, weight: shipping.weight, height: shipping.dimensions.height, width: shipping.dimensions.width, length: shipping.dimensions.depth
          correios.getPrice deliverySpecs, (err, delivery) ->
            #console.log "got price for #{service.type} with specs #{JSON.stringify deliverySpecs}, with response #{JSON.stringify delivery}"
            return cb err if err?
            service.cost += delivery.GrandTotal * quantity if shipping.charge
            service.days = delivery.estimatedDelivery if delivery.estimatedDelivery > service.days
            cb()
      getShippingPrices = []
      for product in products when product.hasShippingInfo()
        quantity = parseInt _.findWhere(items, _id: product._id.toString()).quantity
        getShippingPrices.push getShippingPricesFor pac, product.shipping, quantity
        getShippingPrices.push getShippingPricesFor sedex, product.shipping, quantity
      Q.nfcall async.parallel, getShippingPrices
    .then -> shippingOptions
    .catch (err) -> throw new Error "Erro ao obter custo de postagem.\n#{err}"
