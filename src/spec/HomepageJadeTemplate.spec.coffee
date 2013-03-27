helper  = require './support/SpecHelper'

describe 'Home Page Jade Template', ->
  it 'should display nothing when gets nothing', (done) ->
    helper.getWindowFromView 'index', {}, (err, window, $) ->
      done(err) if err
      appContainerText = $('#app-container').html()
      expect(appContainerText).toBe('Produtos indisponíveis')
      done()
