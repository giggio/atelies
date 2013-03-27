helper = require './support/SpecHelper'

describe 'headless testing', ->
  browser = null
  beforeEach ->
    zombie = new require('zombie')
    browser = new zombie.Browser()
  it 'answers with 200', (done) ->
    browser.visit("http://localhost:3000/")
      .then ->
        expect(browser.success).toBeTruthy()
        done()
      .fail (error) ->
        console.log error
        done(error)
