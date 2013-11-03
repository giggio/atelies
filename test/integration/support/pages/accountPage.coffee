Page          = require './seleniumPage'

module.exports = class AccountResetPasswordPage extends Page
  url: 'account'
  clickResendConfirmationEmail: @::pressButtonAndWait.partial '#resendConfirmationEmail'
  confirmationEmailSentMessage: @::getDialogTitle
