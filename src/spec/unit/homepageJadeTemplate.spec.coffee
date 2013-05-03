#TODO: colocar everyauth no contexto para o teste passar
xdescribe 'Home Page Jade Template', ->
  it 'should display loading message on default view', (done) ->
    getWindowFromView 'index', {products: {}}, (err, window, $) ->
      return done(err) if err
      appContainerText = $('#app-container').html()
      expect(appContainerText).toBe('Carregando...')
      done()
