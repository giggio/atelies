product1 = generator.product.a()
product2 = generator.product.b()

define 'storeData', [], ->
  store: { _id: '2', name: 'store 1', slug: 'store_1' }
  products: [product1, product2]
define [
  'jquery'
  'areas/store/views/product'
  'spec/store/support/generatorHelper'
], ($, ProductView, generator) ->
  productView = null
  el = $('<div></div>')
  describe 'ProductView', ->
    describe 'With inventory', ->
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        spyOn($, "ajax").andCallFake (opt) ->
          opt.success [product1]
        productView = new ProductView el:el
        productView.render 'product_1'
      it 'renders the products', ->
        expect($('#product', el)).toBeDefined()
      it 'show the name', ->
        expect($("#product #name", el).text()).toBe product1.name
      it 'shows the picture', ->
        expect($("#product #picture", el).attr('src')).toBe product1.picture
      it 'shows the id', ->
        expect($("#product #id", el).text()).toBe product1._id
      it 'shows the price', ->
        expect($('#product #price', el).text()).toBe product1.price.toString()
      it 'shows the tags', ->
        expect($('#product #tags', el).text()).toBe product1.tags
      it 'shows the description', ->
        expect($('#product #description', el).text()).toBe product1.description
      it 'shows the height', ->
        expect($('#product #dimensions #height', el).text()).toBe product1.dimensions.height.toString()
      it 'shows the width', ->
        expect($('#product #dimensions #width', el).text()).toBe product1.dimensions.width.toString()
      it 'shows the depth', ->
        expect($('#product #dimensions #depth', el).text()).toBe product1.dimensions.depth.toString()
      it 'shows the weight', ->
        expect($('#product #weight', el).text()).toBe product1.weight.toString()
      it 'shows the inventory', ->
        expect($('#product #inventory', el).text()).toBe '30 itens'
    describe 'Without inventory', ->
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        spyOn($, "ajax").andCallFake (opt) ->
          opt.success [product2]
        productView = new ProductView el:el
        productView.render 'product_2'
      it 'shows there is no inventory/made on demand', ->
        expect($('#product #inventory', el).text()).toBe 'Feito sob encomenda'