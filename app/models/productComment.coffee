mongoose  = require 'mongoose'
async     = require 'async'
Postman   = require './postman'
postman = new Postman()

productCommentSchema = new mongoose.Schema
  body:         type: String, required: true
  date:         type: Date, required: true, default: Date.now
  user:         type: mongoose.Schema.Types.ObjectId, ref: 'user', required: true
  userName:     type: String, required: true
  userEmail:    type: String, required: true
  product:      type: mongoose.Schema.Types.ObjectId, ref: 'product', required: true

productCommentSchema.methods.toSimple = -> title: @title, body: @body, date: @date, userName: @userName, userEmail: @userEmail

module.exports = ProductComment = mongoose.model 'productcomment', productCommentSchema

ProductComment.findByProduct = (product, cb) ->
  productId = if product._id? then product._id else product
  ProductComment.find { product: productId }, cb
ProductComment.create = (commentAttr, cb) ->
  comment = new ProductComment commentAttr
  user = commentAttr.user
  product = commentAttr.product
  comment.userName = user.name
  comment.userEmail = user.email
  comment.validate (err) =>
    return cb err if err?
    product.findAdmins (err, users) =>
      return cb err if err?
      body = "<html>
        <h1>Olá!</h1>
        <div>
          Como você é um dos administradores da loja #{product.storeName} estamos te avisando que o produto <strong>#{product.name}</strong> recebeu um comentário.<br />
        </div>
        <div>
          Clique <a href='https://www.atelies.com.br/#{product.url()}'>aqui</a> para ver o comentário.
        </div>
        <div>&nbsp;</div>
        <div>&nbsp;</div>
        <div>
          Equipe Ateliês
        </div>
        </html>"
      sendMailActions =
        for user in users
          (cb) => postman.sendFromContact user, "Ateliês: O produto #{product.name} da loja #{product.storeName} recebeu um comentário", body, cb
      async.parallel sendMailActions, =>
        cb null, comment
