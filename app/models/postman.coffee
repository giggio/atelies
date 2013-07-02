nodemailer = require 'nodemailer'
class Postman
  @configure = (user, password) ->
    @smtp = nodemailer.createTransport "SMTP",
      service: "Hotmail"
      auth:
        user: user
        pass: password
    @running = true
  @stop = -> @smtp.close() if @running

  @dryrun = off

  send: (from, to, subject, body, cb = (->)) ->
    if Postman.dryrun
      console.log "NOT sending mail, dry run"
      return cb()
    mail =
      from: "'#{from.name}' <#{from.email}>"
      to: "'#{to.name}' <#{to.email}>"
      subject: subject
      html: body
      generateTextFromHTML: true
      forceEmbeddedImages: true
    console.log "Sending mail from #{mail.from} to #{mail.to} with subject '#{mail.subject}'"
    Postman.smtp.sendMail mail, cb

module.exports = Postman

#Postman.configure "contato@atelies.com.br", "somepass"
#p = new Postman()
#p.send {name: "Atelies", email: "contato@atelies.com.br"}, {name: "Giovanni", email:"giggio@giggio.net"}, "Hello2", "<b>Hello world 2</b>"
#p.send {name: "Atelies", email: "contato@atelies.com.br"}, {name: "Giovanni", email:"giggio@giggio.net"}, "Hello", "<b>Hello world</b>", (error, response) =>
  #if error?
    #console.log error
  #else
    #console.log "Message sent: #{response.message}"
  #Postman.smtp.close()
