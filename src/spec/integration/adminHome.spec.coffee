zombie    = new require 'zombie'

describe 'Admin home page', ->
  browser = null
  beforeAll (done) ->
    browser = new zombie.Browser()
    cleanDB (error) ->
      return done error if error
      whenServerLoaded ->
        browser.visit "http://localhost:8000/admin", done
  it 'allows to create a new store', ->
    expect(browser.text("#createStore")).toBe 'Crie uma nova loja'
