require './support/_specHelper'
User     = require '../../app/models/user'
bcrypt   = require 'bcrypt'
AccountPage = require './support/pages/accountPage'
Postman = require '../../app/models/postman'

describe 'Resend Confirmation Email', ->
  user = page = null
  before (done) -> whenServerLoaded done

  describe 'Can resend confirmation email', ->
    before (done) ->
      Postman.sentMails.length = 0
      page = new AccountPage()
      cleanDB (error) ->
        return done error if error
        user = generator.user.e()
        user.save()
        page.loginFor user._id, ->
          page.visit ->
            page.clickResendConfirmationEmail done
    it 'shows email sent message', (done) ->
      page.confirmationEmailSentMessage (msg) ->
        msg.should.equal "E-mail enviado"
        done()
    it 'sent confirmation email', ->
      Postman.sentMails.length.should.equal 1
      mail = Postman.sentMails[0]
      mail.to.should.equal "#{user.name} <#{user.email}>"
      mail.subject.should.equal "Bem vindo ao Ateliês"
