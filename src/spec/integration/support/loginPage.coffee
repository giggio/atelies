module.exports = class AdminCreateStorePage
  constructor: (@browser) ->
  visit: (cb) => @browser.visit "http://localhost:8000/login", cb
  setFieldsAs: (values, cb) =>
    @browser.fill "#email", values.email
    @browser.fill "#password", values.password
  clickLoginButton: (cb) => @browser.pressButtonWait "#login", cb
  errors: => @browser.text '#errors > li'
  emailRequired: => @browser.text "label[for=email]"
  passwordRequired: => @browser.text "label[for=password]"
  loginLinkExists: => @browser.query("#loginPop")?
  adminLinkExists: => @browser.query("#admin")?
  logoutLinkExists: => @browser.query("#logout")?
