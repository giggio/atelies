HomeLayout = require './homeLayout'

module.exports = class RegisterPage extends HomeLayout
  url: 'account/register'
  setFieldsAs: (values, cb) =>
    @browser.fill "#registerForm #email", values.email
    @browser.fill "#registerForm #password", values.password
    @browser.fill "#registerForm #passwordVerify", values.passwordVerify
    @browser.fill "#registerForm #name", values.name
    if values.isSeller then @browser.check "#registerForm #isSeller" else @browser.uncheck "#registerForm #isSeller"
  clickRegisterButton: (cb) => @browser.pressButtonWait "#registerForm #register", cb
  errors: => @browser.text '#errors > li'
  emailRequired: => @browser.text "#registerForm label[for=email]"
  passwordRequired: => @browser.text "#registerForm label[for=password]"
  passwordVerifyMessage: => @browser.text "#registerForm label[for=passwordVerify]"
  nameRequired: => @browser.text "#registerForm label[for=name]"
