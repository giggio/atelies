mongoose    = require 'mongoose'
Product     = require '../models/product'

exports.index = (req, res) ->
  mongoose.connect process.env.CUSTOMCONNSTR_mongo
  db = mongoose.connection
  db.on 'error', (err) -> console.error "connection error:#{err}"
  Product.find (err, products) ->
    console.log err.stack if err
    res.render "index", products: products
