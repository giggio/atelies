define [
  'jquery'
  'areas/admin/views/manageProduct'
], ($, ManageProductView) ->
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
        spyOn($, "ajax").andCallFake (opt) ->
          url  = opt.url
          opt.success product
        manageProductView = new ManageProductView el:el, storeSlug: store.slug, productId: product._id
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
