_s = require('underscore.string')
product1 = { _id: '1', name: 'prod 1', picture: 'http://a.jpg', price: 3.43, storeName: 'store 1', storeSlug: 'store_1' }
product2 = { _id: '2', name: 'prod 2', picture: 'http://b.jpg', price: 7.78, storeName: 'store 2', storeSlug: 'store_2' }
products = [ product1, product2 ]
define 'productsHomeData', -> products
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
    it 'should display all the products', ->
      expect($('#productsHome>tbody>tr', el).length).toBe products.length
    it 'should display the store name for product 1', ->
      expect($("#1_store", el).text()).toBe product1.storeName
    it 'link to the store on product 1', ->
      expect($("#1_store a", el).attr('href')).toBe product1.storeSlug
    it 'should display the store name for product 2', ->
      expect($("#2_store", el).text()).toBe product2.storeName
    it 'links to the store on product 2', ->
      expect($("#2_store a", el).attr('href')).toBe product2.storeSlug
    it 'displays the product name on product 1', ->
      expect($("#1_name", el).text()).toBe product1.name
    it 'displays the picture for product 1', ->
      expect($("#1_picture", el).attr('src')).toBe product1.picture
