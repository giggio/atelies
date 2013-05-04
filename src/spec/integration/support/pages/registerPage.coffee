HomeLayout = require './homeLayout'

module.exports = class RegisterPage extends HomeLayout
  url: 'register'
  setFieldsAs: (values, cb) =>
    @browser.fill "#email", values.email
    @browser.fill "#password", values.password
    @browser.fill "#name", values.name
    if values.isSeller then @browser.check "#isSeller" else @browser.uncheck "#isSeller"
  clickRegisterButton: (cb) => @browser.pressButtonWait "#register", cb
  errors: => @browser.text '#errors > li'
  emailRequired: => @browser.text "label[for=email]"
  passwordRequired: => @browser.text "label[for=password]"
  nameRequired: => @browser.text "label[for=name]"
