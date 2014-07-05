require './support/_specHelper'
User          = require '../../app/models/user'
bcrypt        = require 'bcrypt'
AccountPage   = require './support/pages/accountPage'
Postman       = require '../../app/models/postman'
Q             = require 'q'

describe 'Resend Confirmation Email', ->
  user = page = null
  describe 'Can resend confirmation email', ->
    before ->
      Postman.sentMails.length = 0
      page = new AccountPage()
      cleanDB()
      .then ->
        user = generator.user.e()
        Q.ninvoke user, 'save'
      .then -> page.loginFor user._id
      .then page.visit
      .then page.clickResendConfirmationEmail
    it 'shows email sent message', -> page.confirmationEmailSentMessage().should.become "E-mail enviado"
    it 'sent confirmation email', ->
      Postman.sentMails.length.should.equal 1
      mail = Postman.sentMails[0]
      mail.to.should.equal "#{user.name} <#{user.email}>"
      mail.subject.should.equal "Bem vindo ao Ateliês"
