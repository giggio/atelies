_s = require('underscore.string')
product1 = generator.product.a()
product2 = generator.product.b()
products = [ product1, product2 ]
define 'productsHomeData', -> products
define [
  'jquery'
  'areas/home/views/home'
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
    it 'links to the product page on the product name on product 1', ->
      expect($("#1_name a", el).attr('href')).toBe "#{product1.storeSlug}##{product1.slug}"
    it 'displays the picture for product 1', ->
      expect($("#1_picture img", el).attr('src')).toBe product1.picture
    it 'links to the product page on the picture on product 1', ->
      expect($("#1_picture", el).attr('href')).toBe "#{product1.storeSlug}##{product1.slug}"