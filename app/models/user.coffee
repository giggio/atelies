mongoose  = require 'mongoose'
_         = require 'underscore'
Store     = require './store'
config    = require '../helpers/config'
Postman   = require './postman'
postman = new Postman()

userSchema = new mongoose.Schema
  name:             type: String, required: true
  email:            type: String, required: true
  passwordHash:     type: String, required: true
  isSeller:         type: Boolean, default: false
  stores:           [{type: mongoose.Schema.Types.ObjectId, ref: 'store'}]
  deliveryAddress:
    street:         String
    street2:        String
    city:           String
    state:          String
    zip:            String
  phoneNumber:      String
  loginError:       Number
  verified:         type: Boolean, default: false

userSchema.methods.createStore = ->
  store = new Store()
  @stores.push store
  store
userSchema.methods.hasStore = (store) ->
  if store._id?
    id = store._id.toString()
  else
    id = store.toString()
  storeFound = _.find @stores, (_id) -> id is _id.toString()
  storeFound?
userSchema.methods.carefulLogin = -> @loginError >= 3
userSchema.methods.verifyPassword = (passwordToVerify, cb) ->
  bcrypt = require 'bcrypt'
  bcrypt.compare passwordToVerify, @passwordHash, (error, succeeded) =>
    if succeeded
      if @loginError isnt 0
        @loginError = 0
      else
        return cb null, true
    else
      @loginError++
    @save (err, u) =>
      cb error, succeeded
userSchema.methods.setPassword = (password) ->
  bcrypt = require 'bcrypt'
  salt = bcrypt.genSaltSync 10
  @passwordHash = bcrypt.hashSync password, salt
userSchema.methods.toSimpleUser = ->
  _id: @_id
  name: @name
  email: @email
  deliveryAddress: @deliveryAddress
  phoneNumber: @phoneNumber
  verified: @verified
  isSeller: @isSeller
userSchema.methods.sendMailConfirmRegistration = (cb) ->
  registrationLink = "#{config.secureUrl}/account/verifyUser/#{@_id}"
  body = "<html>
    <h1>Olá #{@name}!</h1>
    <h2>Bem vindo ao Ateliês!</h2>
    <div>
      Recebemos um registro de novo usuário no Ateliês indicando este e-mail (#{@email}). Gostaríamos de confirmar que ele é mesmo seu!
    </div>
    <div>
      Clique <a href='#{registrationLink}'>aqui</a> para confirmar seu registro. Ou copie e cole o texto abaixo:</br>
      #{registrationLink}
    </div>
    <div>
      Caso você não tenha se registrado basta nos comunicar em contato@atelies.com.br que excluiremos o usuário.
    </div>
    </html>"
  postman.sendFromContact @, "Bem vindo ao Ateliês", body, cb
  
User = mongoose.model 'user', userSchema
User.findByEmail = (email, cb) -> User.findOne email: email, cb

module.exports = User
