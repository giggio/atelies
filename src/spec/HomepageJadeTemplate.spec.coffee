jade  = require 'jade'
fs    = require 'fs'
path  = require 'path'
jsdom = require("jsdom").jsdom

describe 'Home Page Jade Template', ->
  it 'should display nothing when gets nothing', (done) ->
    filename = path.join(__dirname, '..', 'views', 'index.jade')
    fs.readFile filename, 'utf8', (err, jadeContent) ->
      throw err if err
      try
        jadeResult = jade.compile(jadeContent, {pretty: true, filename: filename})
      catch error
        console.log error
      html = jadeResult({})
      jqueryFile = fs.readFileSync(path.join(__dirname, "../public/javascripts/lib/jquery.min.js".split('/')...)).toString()
      jsdom.env html: html, src: [jqueryFile], done: (error, window) ->
        throw error if error
        $ = window.$
        appContainerText = $('#app-container').html()
        expect(appContainerText).toBe('Produtos indisponíveis')
        done()
