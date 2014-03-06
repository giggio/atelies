Page          = require './seleniumPage'

module.exports = class AccountResetPasswordPage extends Page
  visit: (_id, resetKey) => super "account/resetPassword?_id=#{_id}&resetKey=#{resetKey}"
  clickChangePasswordButton: @::pressButton.partial '#changePassword'
  setFieldsAs: (v) =>
    @type "#passwordVerify", v.passwordVerify
    .then => @type "#newPassword", v.newPassword
  errorMsg: @::getText.partial '#error'
