module.exports = class AdminCreateStorePage
  constructor: (@browser) ->
  visit: (cb) => @browser.visit "http://localhost:8000/register", cb
  setFieldsAs: (values, cb) =>
    @browser.fill "#email", values.email
    @browser.fill "#password", values.password
    @browser.fill "#name", values.name
  clickRegisterButton: (cb) => @browser.pressButtonWait "#register", cb
  errors: => @browser.text '#errors > li'
  emailRequired: => @browser.text "label[for=email]"
  passwordRequired: => @browser.text "label[for=password]"
  nameRequired: => @browser.text "label[for=name]"
  loginLinkExists: => @browser.query("#loginPop")?
  adminLinkExists: => @browser.query("#admin")?
  logoutLinkExists: => @browser.query("#logout")?
