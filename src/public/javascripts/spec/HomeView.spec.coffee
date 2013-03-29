define 'productsHomeData', ->
    { id: 1, productName: 'prod 1', picture: 'http://a.jpg', price: 3.43, storeId: 3 }
    { id: 2, productName: 'prod 2', picture: 'http://b.jpg', price: 7.78, storeId: 4 }
  
define [
  'jquery'
  'views/Home'
], ($, HomeView) ->
  homeView = null
  el = $('<div></div>')
  describe 'HomeView', ->
    beforeEach ->
      homeView = new HomeView el:el
      homeView.render()
    it 'should render the products', ->
      expect($('#productsHome', el)).toBeDefined()
