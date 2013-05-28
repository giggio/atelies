HomeLayout = require './homeLayout'

module.exports = class LoginPage extends HomeLayout
  url: 'login'
  setFieldsAs: (values) =>
    @browser.fill "#loginForm #email", values.email
    @browser.fill "#loginForm #password", values.password
  clickLoginButton: (cb) => @browser.pressButtonWait "#loginForm #login", cb
  errors: => @browser.text '#errors > li'
  emailRequired: => @browser.text "#loginForm label[for=email]"
  passwordRequired: => @browser.text "#loginForm label[for=password]"
  loginWith: (values, cb) =>
    @setFieldsAs values
    @clickLoginButton cb
  navigateAndLoginWith: (user, cb) ->
    @visit => @loginWith user, cb
