HomeLayout = require './homeLayout'

module.exports = class LoginPage extends HomeLayout
  url: 'login'
  setFieldsAs: (values) =>
    @browser.fill "#email", values.email
    @browser.fill "#password", values.password
  clickLoginButton: (cb) => @browser.pressButtonWait "#login", cb
  errors: => @browser.text '#errors > li'
  emailRequired: => @browser.text "label[for=email]"
  passwordRequired: => @browser.text "label[for=password]"
  loginWith: (values, cb) =>
    @setFieldsAs values
    @clickLoginButton cb
  navigateAndLoginWith: (user, cb) ->
    @visit => @loginWith user, cb
