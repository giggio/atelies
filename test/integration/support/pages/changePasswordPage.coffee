HomeLayout = require './homeLayout'

module.exports = class LoginPage extends HomeLayout
  url: 'account/changePassword'
  setFieldsAs: (values) =>
    @browser.fill "#changePasswordForm #password", values.password
    @browser.fill "#changePasswordForm #passwordVerify", values.passwordVerify
    @browser.fill "#changePasswordForm #newPassword", values.newPassword
  clickChangePasswordButton: (cb) => @browser.pressButtonWait "#changePasswordForm #changePassword", cb
  errors: => @browser.text '#errors > p'
  passwordRequired: => @browser.text "#changePasswordForm label[for=password]"
  newPasswordRequired: => @browser.text "#changePasswordForm label[for=newPassword]"
  passwordVerifyMessage: => @browser.text "#changePasswordForm label[for=passwordVerify]"
