product =
  _id: '1'
  name: 'prod 1'
  slug: 'prod_1'
  picture: 'http://c.jpg'
  price: 3.43
  storeName: 'store 1'
  storeSlug: 'store_1'
  url: 'store_1#prod_1'
  tags: 'abc, def'
  description: "Mussum ipsum cacilds, vidis litro abertis. Consetis adipiscings elitis. Pra lá , depois divoltis porris, paradis. Paisis, filhis, espiritis santis. Mé faiz elementum girarzis, nisi eros vermeio, in elementis mé pra quem é amistosis quis leo. Manduma pindureta quium dia nois paga. Sapien in monti palavris qui num significa nadis i pareci latim. Interessantiss quisso pudia ce receita de bolis, mais bolis eu num gostis."
  dimensions:
    height: 10
    width: 20
    depth: 30
  weight: 40
  hasInventory: true
  inventory: 30

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
      spyOn($, "ajax").andCallFake (opt) ->
        opt.success [product]
      productView = new ProductView el:el
      productView.render 'product_1'
    it 'renders the products', ->
      expect($('#product', el)).toBeDefined()
    it 'show the name', ->
      expect($("#product #name", el).text()).toBe product.name
    it 'shows the picture', ->
      expect($("#product #picture", el).attr('src')).toBe product.picture
    it 'shows the id', ->
      expect($("#product #id", el).text()).toBe product._id
    it 'shows the price', ->
      expect($('#product #price', el).text()).toBe product.price.toString()
    it 'shows the tags', ->
      expect($('#product #tags', el).text()).toBe product.tags
    it 'shows the description', ->
      expect($('#product #description', el).text()).toBe product.description
    it 'shows the height', ->
      expect($('#product #dimensions #height', el).text()).toBe product.dimensions.height.toString()
    it 'shows the width', ->
      expect($('#product #dimensions #width', el).text()).toBe product.dimensions.width.toString()
    it 'shows the depth', ->
      expect($('#product #dimensions #depth', el).text()).toBe product.dimensions.depth.toString()
    it 'shows the weight', ->
      expect($('#product #weight', el).text()).toBe product.weight.toString()
    it 'shows the inventory', ->
      expect($('#product #inventory', el).text()).toBe '30 itens'
