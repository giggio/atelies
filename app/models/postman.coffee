nodemailer  = require 'nodemailer'
Q           = require 'q'
config      = require '../helpers/config'
verboseTest = config.test.verbose
module.exports = class Postman
  @configure = (id, secret) ->
    unless @dryrun
      @smtp = nodemailer.createTransport "SES",
        AWSAccessKeyID: id
        AWSSecretKey: secret
      @running = true
  @stop = -> @smtp.close() if @running

  @classProperty 'dryrun',
    get: =>
      @_dryrun = off unless @_dryrun?
      @_dryrun
    set: (val) =>
      @_dryrun = val
      if val
        @sentMails = []

  send: (from, to, subject, body) ->
    mail =
      from: "#{from.name} <contato@atelies.com.br>"
      to: "#{to.name} <#{to.email}>"
      subject: subject
      html: body
      generateTextFromHTML: true
      forceEmbeddedImages: true
    if from.email isnt 'contato@atelies.com.br'
      mail.replyTo = "#{from.name} <#{from.email}>"
    if Postman.dryrun
      if !TEST or verboseTest
        console.log new Date().toLocaleTimeString(), "Postman.send: NOT sending mail to #{mail.to} with subject #{mail.subject}, dry run".cyan
      Postman.sentMails.push mail
      Q.fcall ->
    else
      #console.log "Sending mail from #{mail.from} to #{mail.to} with subject '#{mail.subject}'"
      Q.ninvoke Postman.smtp, 'sendMail', mail

  sendFromContact: @::send.partial name:'Ateliês', email:'contato@atelies.com.br'
