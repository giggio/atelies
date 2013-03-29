define [
  'jquery'
  'views/Home'
], ($, HomeView) ->
  console.log 1
  homeView = null
  el = $('<div></div>')
  describe 'HomeView', ->
    beforeEach ->
      homeView = new HomeView el:el
      homeView.render()
    it 'should render the products', ->
      expect($('#productsHome', el)).toBeDefined()
