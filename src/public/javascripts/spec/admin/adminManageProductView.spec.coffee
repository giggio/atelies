define [
  'jquery'
  'areas/admin/views/manageProduct'
  'areas/admin/models/product'
], ($, ManageProductView, ProductModel) ->
  el = $('<div></div>')
  describe 'ManageProductView', ->
    describe 'Shows product', ->
      url = product = store = manageProductView = null
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        store = generator.store.a()
        product = generator.product.a()
        productModel = new ProductModel product
        manageProductView = new ManageProductView el:el, product:productModel
        manageProductView.render()
      it 'shows product', ->
        expect($("#_id", el).text()).toBe product._id
        expect($("#name", el).val()).toBe product.name
        expect($("#price", el).val()).toBe product.price.toString()
        expect($("#slug", el).text()).toBe product.slug
        expect($("#picture", el).val()).toBe product.picture
        expect($("#tags", el).val()).toBe product.tags
        expect($("#description", el).val()).toBe product.description
        expect($("#height", el).val()).toBe product.dimensions.height.toString()
        expect($("#width", el).val()).toBe product.dimensions.width.toString()
        expect($("#depth", el).val()).toBe product.dimensions.depth.toString()
        expect($("#weight", el).val()).toBe product.weight.toString()
        expect($("#hasInventory", el).prop('checked')).toBe product.hasInventory
        expect($("#inventory", el).val()).toBe product.inventory.toString()

    xdescribe 'Updates product', ->
      url = updatedProduct = product = store = manageProductView = null
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        store = generator.store.a()
        product = generator.product.a()
        updatedProduct = generator.product.b()
        spyOn($, "ajax").andCallFake (opt) ->
          url  = opt.url
          opt.success product
        manageProductView = new ManageProductView el:el, storeSlug: store.slug, productId: product._id
        manageProductView.render()
        $("#name", el).val updatedProduct.name
        $("#price", el).val updatedProduct.price
        $("#picture", el).val updatedProduct.picture
        $("#tags", el).val updatedProduct.tags
        $("#description", el).val updatedProduct.description
        $("#height", el).val updatedProduct.dimensions.height
        $("#width", el).val updatedProduct.dimensions.width
        $("#depth", el).val updatedProduct.dimensions.depth
        $("#weight", el).val updatedProduct.weight
        $("#hasInventory", el).prop 'checked', updatedProduct.hasInventory
        $("#inventory", el).val updatedProduct.inventory
        $('#updateProduct', el).trigger 'click'
      it 'updated product', ->
      it 'navigated to store manage', ->
