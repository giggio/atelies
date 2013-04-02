helper    = require './support/SpecHelper'
Product   = require '../models/product'
zombie    = new require('zombie')

describe 'With a NodeJS instance', ->
  browser = null
  beforeEach -> browser = new zombie.Browser()
  describe 'headless testing', ->
    it 'answers with 200', (done) ->
      helper.whenServerLoaded ->
        product1 = new Product(name: 'name1', picture: 'http://aa.com/picture1.jpg', price: 11.1)
        product2 = new Product(name: 'name2', picture: 'http://aa.com/picture2.jpg', price: 12.2)
        product1.save()
        product2.save()
        browser.visit("http://localhost:8000/")
          .then ->
            expect(browser.success).toBeTruthy()
            expect(browser.query('table#productsHome tbody').children.length).toBe 2
            expect(browser.text('#' + product1.id)).toBe product1.id
          .fail (error) ->
            console.log "Error visiting. " + error.stack
          .then done, done
