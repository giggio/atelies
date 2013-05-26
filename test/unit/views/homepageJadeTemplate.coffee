require './support/_specHelper'
describe 'Home Page Jade Template', ->
  it 'should display loading message on default view', (done) ->
    getWindowFromView 'index', {products: [], stores: []}, (err, window, $) ->
      return done(err) if err
      appContainerText = $('#app-container').html()
      expect(appContainerText).to.equal 'Carregando...'
      done()
