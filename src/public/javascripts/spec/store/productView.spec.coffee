product1  = generator.product.a()
product2  = generator.product.b()
store1    = generator.store.a()
store2    = generator.store.b()

define 'storeData', [], ->
  #store: store
  #products: [product1, product2]
define [
  'jquery'
  'areas/store/views/product'
], ($, ProductView) ->
  productView = null
  el = $('<div></div>')
  describe 'ProductView', ->
    describe 'Store with banner and product with inventory', ->
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        spyOn($, "ajax").andCallFake (opt) ->
          opt.success [product1]
        productView = new ProductView el:el
        productView.storeData =
          store: store1
          products: [product1, product2]
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
      describe 'Store details', ->
        it 'shows the store name', ->
          expect($('#storeName', el).text()).toBe store1.name
        it 'shows phone number', ->
          expect($('#storePhoneNumber', el).text()).toBe store1.phoneNumber
        it 'shows City', ->
          expect($('#storeCity', el).text()).toBe store1.city
        it 'shows State', ->
          expect($('#storeState', el).text()).toBe store1.state
        it 'shows other store url', ->
          expect($('#storeOtherUrl', el).text()).toBe store1.otherUrl
        it 'does not show the store name header', ->
          expect($('#storeNameHeader', el).length).toBe 0
        it 'shows store banner', ->
          expect($('#storeBanner', el).attr('src')).toBe store1.banner
    describe 'Store without banner and product without inventory', ->
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        spyOn($, "ajax").andCallFake (opt) ->
          opt.success [product2]
        productView = new ProductView el:el
        productView.storeData =
          store: store2
          products: [product1, product2]
        productView.render 'product_2'
      it 'shows there is no inventory/made on demand', ->
        expect($('#product #inventory', el).text()).toBe 'Feito sob encomenda'
      it 'shows store name header', ->
        expect($('#storeNameHeader', el).text()).toBe store2.name
      it 'does not show the store banner', ->
        expect($('#storeBanner', el).length).toBe 0
