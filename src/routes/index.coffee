mongoose    = require 'mongoose'
Product     = require '../models/product'

exports.index = (req, res) ->
  mongoose.connect process.env.CUSTOMCONNSTR_mongo
  mongoose.connection.on 'error', (err) ->
    console.error "connection error:#{err.stack}"
    throw err
  mongoose.connection.once 'open', ->
    Product.find (err, products) ->
      console.log err.stack if err
      res.render "index", products: products
      mongoose.connection.close()
      mongoose.disconnect()
