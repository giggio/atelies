HomeLayout = require './homeLayout'

module.exports = class RegisterPage extends HomeLayout
  url: 'account/register'
  setFieldsAs: (values, cb) =>
    @browser.fill "#registerForm #email", values.email
    @browser.fill "#registerForm #password", values.password
    @browser.fill "#registerForm #passwordVerify", values.passwordVerify
    @browser.fill "#registerForm #name", values.name
    @browser.fill "#registerForm #deliveryStreet", values.deliveryStreet
    @browser.fill "#registerForm #deliveryStreet2", values.deliveryStreet2
    @browser.fill "#registerForm #deliveryCity", values.deliveryCity
    @browser.select "#registerForm #deliveryState", values.deliveryState if values.deliveryState?
    @browser.fill "#registerForm #deliveryZIP", values.deliveryZIP
    @browser.fill "#registerForm #phoneNumber", values.phoneNumber
    if values.termsOfUse?
      if values.termsOfUse then @browser.check "#registerForm #termsOfUse" else @browser.uncheck "#registerForm #termsOfUse"
    if values.isSeller then @browser.check "#registerForm #isSeller" else @browser.uncheck "#registerForm #isSeller"
  clickRegisterButton: (cb) => @browser.pressButtonWait "#registerForm #register", cb
  errors: => @browser.text '#errors > li'
  emailRequired: => @browser.text "#registerForm label[for=email]"
  passwordRequired: => @browser.text "#registerForm label[for=password]"
  passwordVerifyMessage: => @browser.text "#registerForm label[for=passwordVerify]"
  nameRequired: => @browser.text "#registerForm label[for=name]"
