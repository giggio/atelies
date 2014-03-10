require './support/_specHelper'
describe 'Home Page Jade Template', ->
  it 'should display loading message on default view', (done) ->
    getWindowFromView 'home/index', {products: [], productsFeatured: [], stores: []}, (err, window, $) ->
      return done(err) if err
      appContainerText = $('#app-container .home').html()
      expect(appContainerText).to.equal 'Carregando...'
      done()
