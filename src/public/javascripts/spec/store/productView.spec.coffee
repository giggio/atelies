product = { _id: '1', name: 'prod 1', slug: 'prod_1', picture: 'http://c.jpg', price: 3.43, storeName: 'store 1', storeSlug: 'store_1', url: 'store_1#prod_1' }
define 'storeData', [], ->
  store: { _id: '2', name: 'store 1', slug: 'store_1' }
  products: [product]
define [
  'jquery'
  'areas/store/views/product'
], ($, ProductView) ->
  productView = null
  el = $('<div></div>')
  describe 'ProductView', ->
    beforeEachCalled = false
    beforeEach ->
      return if beforeEachCalled
      beforeEachCalled = true
      # TODO: try to find out a way to spy on $
      # you have to spy on global.$, not on $. For some reason, they are not the same during ajax calls
      spyOn(global.$, "ajax").andCallFake (opt) ->
        opt.success [product]
      productView = new ProductView el:el
      productView.render 'product_1'
    it 'should render the products', ->
      expect($('#product', el)).toBeDefined()
    it 'displays the product name', ->
      expect($("#product #name", el).text()).toBe product.name
    it 'shows the product picture', ->
      expect($("#product #picture", el).attr('src')).toBe product.picture
    it 'displays the product id', ->
      expect($("#product #id", el).text()).toBe product._id
