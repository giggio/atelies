Page          = require './seleniumPage'

module.exports = class AccountForgotPasswordPage extends Page
  url: "account/forgotPassword"
  clickRequestPasswordReset: @::pressButton.partial '#forgotPassword'
  setEmail: @::type.partial "#forgotPasswordForm #email"
  errorMsg: @::getText.partial '#error'
