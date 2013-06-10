HomeLayout = require './homeLayoutSelenium'

module.exports = class LoginPage extends HomeLayout
  url: 'account/login'
  setFieldsAs: (values) ->
    @type "#loginForm #email", values.email
    @type "#loginForm #password", values.password
  clickLoginButton: (cb) -> @pressButton "#loginForm #login", cb
  errors: (cb) -> @getText '#errors > li', cb
  emailRequired: (cb) -> @getText "#loginForm label[for=email]", cb
  passwordRequired: (cb) -> @getText "#loginForm label[for=password]", cb
  loginWith: (values, cb) ->
    @setFieldsAs values
    @clickLoginButton cb
  navigateAndLoginWith: (user, cb) ->
    @visit()
    @loginWith user, cb
