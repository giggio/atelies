HomeLayout = require './homeLayout'

module.exports = class RegisterPage extends HomeLayout
  url: 'account/register'
  setFieldsAs: (values) =>
    @type "#registerForm #email", values.email
    .then => @type "#registerForm #password", values.password
    .then => @type "#registerForm #passwordVerify", values.passwordVerify
    .then => @type "#registerForm #name", values.name
    .then => @type "#registerForm #deliveryStreet", values.deliveryStreet
    .then => @type "#registerForm #deliveryStreet2", values.deliveryStreet2
    .then => @type "#registerForm #deliveryCity", values.deliveryCity
    .then => @type "#registerForm #deliveryZIP", values.deliveryZIP
    .then => @type "#registerForm #phoneNumber", values.phoneNumber
    .then => @checkOrUncheck "#registerForm #isSeller", values.isSeller
    .then => if values.termsOfUse? then @checkOrUncheck "#registerForm #termsOfUse", values.termsOfUse
    .then => if values.deliveryState? then @select "#registerForm #deliveryState", values.deliveryState
  clickRegisterButton: @::pressButtonAndWait.partial "#registerForm #register"
  clickManualEntry: ->
    @pressButtonAndWait "#manualEntry"
    .then => @hasElementAndIsVisible "#registerForm #email"
    .then (itIs) => @pressButtonAndWait "#manualEntry" unless itIs
  errors: @::getText.partial '#errors > li'
  hasErrors: @::hasElement.partial '#errors > li'
  emailRequired: @::getText.partial "#registerForm label[for=email]"
  passwordRequired: @::getText.partial "#registerForm label[for=password]"
  passwordVerifyMessage: @::getText.partial "#registerForm label[for=passwordVerify]"
  nameRequired: @::getText.partial "#registerForm label[for=name]"
