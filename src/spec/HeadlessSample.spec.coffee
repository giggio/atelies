helper = require './support/SpecHelper'

whenDone = (condition, callback) ->
  if condition()
    callback()
  else
    setTimeout((-> whenDone(condition, callback)), 1000)

describe 'With a NodeJS instance', ->
  browser = null
  app = null
  beforeEach ->
    helper.startServer (server) -> app = server
    zombie = new require('zombie')
    browser = new zombie.Browser()
  afterEach ->
    app.close()
  describe 'headless testing', ->
    it 'answers with 200', (done) ->
      whenDone (-> app isnt null), ->
        browser.visit("http://localhost:3000/")
          .then ->
            expect(browser.success).toBeTruthy()
            done()
          .fail (error) ->
            console.log error
            done(error)
