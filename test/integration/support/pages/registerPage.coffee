HomeLayout = require './homeLayout'

module.exports = class RegisterPage extends HomeLayout
  url: 'account/register'
  setFieldsAs: (values, cb) =>
    selectState = (cb) =>
      if values.deliveryState?
        return @select "#registerForm #deliveryState", values.deliveryState, cb
      cb()
    selectState =>
      @type "#registerForm #email", values.email
      @type "#registerForm #password", values.password
      @type "#registerForm #passwordVerify", values.passwordVerify
      @type "#registerForm #name", values.name
      @type "#registerForm #deliveryStreet", values.deliveryStreet
      @type "#registerForm #deliveryStreet2", values.deliveryStreet2
      @type "#registerForm #deliveryCity", values.deliveryCity
      @type "#registerForm #deliveryZIP", values.deliveryZIP
      @type "#registerForm #phoneNumber", values.phoneNumber
      @checkOrUncheck "#registerForm #isSeller", values.isSeller, =>
        if values.termsOfUse?
          return @checkOrUncheck "#registerForm #termsOfUse", values.termsOfUse, cb
        cb()
  clickRegisterButton: @::pressButtonAndWait.partial "#registerForm #register"
  clickManualEntry: (cb) ->
    @pressButtonAndWait "#manualEntry", =>
      @hasElementAndIsVisible "#registerForm #email", (itIs) =>
        return cb() if itIs
        @pressButtonAndWait "#manualEntry", cb
  errors: @::getText.partial '#errors > li'
  hasErrors: @::hasElement.partial '#errors > li'
  emailRequired: @::getText.partial "#registerForm label[for=email]"
  passwordRequired: @::getText.partial "#registerForm label[for=password]"
  passwordVerifyMessage: @::getText.partial "#registerForm label[for=passwordVerify]"
  nameRequired: @::getText.partial "#registerForm label[for=name]"
