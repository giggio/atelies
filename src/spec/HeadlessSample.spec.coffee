helper = require './support/SpecHelper'

describe 'With a NodeJS instance', ->
  browser = null
  beforeEach ->
    zombie = new require('zombie')
    browser = new zombie.Browser()
  afterEach (done) ->
    browser.close()
    done()
  describe 'headless testing', ->
    it 'answers with 200', (done) ->
      helper.whenServerLoaded ->
        browser.visit("http://localhost:8000/")
          .then ->
            expect(browser.success).toBeTruthy()
            done()
          .fail (error) ->
            console.log "Error visiting. " + error.stack
            done error
