helper = require './support/SpecHelper'

describe 'With a NodeJS instance', ->
  browser = null
  beforeEach ->
    zombie = new require('zombie')
    browser = new zombie.Browser()
  describe 'headless testing', ->
    it 'answers with 200', (done) ->
      helper.whenServerLoaded ->
        browser.visit("http://localhost:3000/")
          .then ->
            expect(browser.success).toBeTruthy()
            done()
          .fail (error) ->
            console.log error
            done(error)
