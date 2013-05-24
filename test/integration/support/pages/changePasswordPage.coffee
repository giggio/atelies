HomeLayout = require './homeLayout'

module.exports = class LoginPage extends HomeLayout
  url: 'account/changePassword'
  setFieldsAs: (values) =>
    @browser.fill "#password", values.password
    @browser.fill "#passwordVerify", values.passwordVerify
    @browser.fill "#newPassword", values.newPassword
  clickChangePasswordButton: (cb) => @browser.pressButtonWait "#changePassword", cb
  errors: => @browser.text '#errors > p'
  passwordRequired: => @browser.text "label[for=password]"
  newPasswordRequired: => @browser.text "label[for=newPassword]"
  passwordVerifyRequired: => @browser.text "label[for=passwordVerify]"
