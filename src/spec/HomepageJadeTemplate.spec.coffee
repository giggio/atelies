describe 'Home Page Jade Template', ->
  it 'should display loading message on default view', (done) ->
    getWindowFromView 'index', {products: {}}, (err, window, $) ->
      done(err) if err
      appContainerText = $('#app-container').html()
      expect(appContainerText).toBe('Carregando...')
      done()
