Page          = require './seleniumPage'

module.exports = class AccountResetPasswordPage extends Page
  url: 'account'
  clickResendConfirmationEmail: @::pressButton.partial '#resendConfirmationEmail'
  confirmationEmailSentMessage: @::getDialogTitle
