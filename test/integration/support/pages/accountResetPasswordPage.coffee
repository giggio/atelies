Page          = require './seleniumPage'

module.exports = class AccountResetPasswordPage extends Page
  url: ''
  visit: (_id, resetKey, cb) => super "account/resetPassword?_id=#{_id}&resetKey=#{resetKey}", cb
  clickChangePasswordButton: @::pressButton.partial '#changePassword'
  setFieldsAs: (v) =>
    @type "#passwordVerify", v.passwordVerify
    @type "#newPassword", v.newPassword
  errorMsg: @::getText.partial '#error'
