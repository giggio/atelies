define [
  'jquery'
  'areas/store/views/product'
  'backbone'
  'areas/store/models/cart'
  'underscore'
  'areas/store/models/product'
], ($, ProductView, Backbone, Cart, _, Product) ->
  product1  = generator.product.a()
  product2  = generator.product.b()
  store1    = generator.store.a()
  store2    = generator.store.b()
  productView = null
  el = $('<div></div>')
  describe 'ProductView', ->
    describe 'Store with banner and product with inventory', ->
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        productView = new ProductView el:el, store: store1, product: new Product product1
        productView.render 'product_1'
      it 'renders the products', ->
        expect($('#product1', el)).toBeDefined()
      it 'show the name', ->
        expect($("#product1 #name", el).text()).toBe product1.name
      it 'shows the picture', ->
        expect($("#product1 #picture", el).attr('src')).toBe product1.picture
      it 'shows the id', ->
        expect($("#product1 #id", el).text()).toBe product1._id
      it 'shows the price', ->
        expect($('#product1 #price', el).text()).toBe product1.price.toString()
      it 'shows the tags', ->
        expect($('#product1 #tags', el).text()).toBe product1.tags
      it 'shows the description', ->
        expect($('#product1 #description', el).text()).toBe product1.description
      it 'shows the height', ->
        expect($('#product1 #dimensions #height', el).text()).toBe product1.dimensions.height.toString()
      it 'shows the width', ->
        expect($('#product1 #dimensions #width', el).text()).toBe product1.dimensions.width.toString()
      it 'shows the depth', ->
        expect($('#product1 #dimensions #depth', el).text()).toBe product1.dimensions.depth.toString()
      it 'shows the weight', ->
        expect($('#product1 #weight', el).text()).toBe product1.weight.toString()
      it 'shows the inventory', ->
        expect($('#product1 #inventory', el).text()).toBe '30 itens'
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
        productView = new ProductView el:el, store: store2, product: new Product product2
        productView.render 'product_2'
      it 'shows there is no inventory/made on demand', ->
        expect($('#product2 #inventory', el).text()).toBe 'Feito sob encomenda'
      it 'shows store name header', ->
        expect($('#storeNameHeader', el).text()).toBe store2.name
      it 'does not show the store banner', ->
        expect($('#storeBanner', el).length).toBe 0
    describe 'Purchasing an item', ->
      spy = null
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        Cart.get().clear()
        spy = spyOn Backbone.history, "navigate"
        productView = new ProductView el:el, store: store2, product: new Product product2
        productView.render 'product_2'
        productView.purchase()
      it 'adds an item to the cart', ->
        expect(_.findWhere(Cart.get(store2.slug).items(), _id: product2._id).id).not.toBeNull()
      it 'navigated', ->
        expect(spy).toHaveBeenCalledWith '#cart', trigger:true

