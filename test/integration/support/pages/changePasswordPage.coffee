HomeLayout = require './homeLayout'

module.exports = class LoginPage extends HomeLayout
  url: 'account/changePassword'
  setFieldsAs: (values) =>
    @type "#changePasswordForm #password", values.password
    @type "#changePasswordForm #passwordVerify", values.passwordVerify
    @type "#changePasswordForm #newPassword", values.newPassword
  clickChangePasswordButton: @::pressButton.partial "#changePasswordForm #changePassword"
  errors: @::getText.partial '#errors > p'
  hasErrors: @::hasElement.partial '#errors > p'
  passwordRequired: @::getText.partial "#changePasswordForm label[for=password]"
  newPasswordRequired: @::getText.partial "#changePasswordForm label[for=newPassword]"
  passwordVerifyMessage: @::getText.partial "#changePasswordForm label[for=passwordVerify]"
