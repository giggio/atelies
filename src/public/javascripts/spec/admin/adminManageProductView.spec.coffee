define [
  'jquery'
  'areas/admin/views/manageProduct'
  'areas/admin/models/product'
  'areas/admin/models/products'
  'backboneConfig'
], ($, ManageProductView, Product, Products) ->
  el = $('<div></div>')
  describe 'ManageProductView', ->
    describe 'Shows product', ->
      product = store = manageProductView = null
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        store = generator.store.a()
        product = generator.product.a()
        products = new Products [product], storeSlug: product.storeSlug
        productModel = products.at 0
        manageProductView = new ManageProductView el:el, product: productModel
        manageProductView.render()
      it 'shows product', ->
        expect($("#_id", el).text()).toBe product._id
        expect($("#name", el).val()).toBe product.name
        expect($("#price", el).val()).toBe product.price.toString()
        expect($("#slug", el).text()).toBe product.slug
        expect($("#picture", el).val()).toBe product.picture
        expect($("#tags", el).val()).toBe product.tags
        expect($("#description", el).val()).toBe product.description
        expect($("#height", el).val()).toBe product.height.toString()
        expect($("#width", el).val()).toBe product.width.toString()
        expect($("#depth", el).val()).toBe product.depth.toString()
        expect($("#weight", el).val()).toBe product.weight.toString()
        expect($("#hasInventory", el).prop('checked')).toBe product.hasInventory
        expect($("#inventory", el).val()).toBe product.inventory.toString()

    describe 'Updates product', ->
      historySpy = productPosted = dataPosted = ajaxSpy = updatedProduct = product = store = manageProductView = null
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        ajaxSpy = spyOn($, 'ajax').andCallFake (opt) =>
          dataPosted = opt
          productPosted = JSON.parse opt.data
          opt.success()
        historySpy = spyOn(Backbone.history, "navigate")
        store = generator.store.a()
        product = generator.product.a()
        updatedProduct = generator.product.b()
        products = new Products [product], storeSlug: product.storeSlug
        productModel = products.at 0
        manageProductView = new ManageProductView el:el, product: productModel
        manageProductView.render()
        $("#name", el).val(updatedProduct.name).change()
        $("#price", el).val(updatedProduct.price).change()
        $("#picture", el).val(updatedProduct.picture).change()
        $("#tags", el).val(updatedProduct.tags).change()
        $("#description", el).val(updatedProduct.description).change()
        $("#height", el).val(updatedProduct.height).change()
        $("#width", el).val(updatedProduct.width).change()
        $("#depth", el).val(updatedProduct.depth).change()
        $("#weight", el).val(updatedProduct.weight).change()
        $("#hasInventory", el).prop('checked', updatedProduct.hasInventory).change()
        $("#inventory", el).val(updatedProduct.inventory).change()
        $('#updateProduct', el).trigger 'click'
      it 'updated product', ->
        expect(ajaxSpy).toHaveBeenCalled()
        expect(productPosted.name).toBe updatedProduct.name
        expect(productPosted.price).toBe updatedProduct.price
        expect(productPosted.picture).toBe updatedProduct.picture
        expect(productPosted.tags).toBe updatedProduct.tags
        expect(productPosted.description).toBe updatedProduct.description
        expect(productPosted.height).toBe updatedProduct.height
        expect(productPosted.width).toBe updatedProduct.width
        expect(productPosted.depth).toBe updatedProduct.depth
        expect(productPosted.weight).toBe updatedProduct.weight
        expect(productPosted.hasInventory).toBe updatedProduct.hasInventory
        expect(productPosted.inventory).toBe ''
      it 'navigated to store manage', ->
        expect(historySpy).toHaveBeenCalledWith "manageStore/#{product.storeSlug}", trigger:true
      it 'posted to correct url', ->
        expect(dataPosted.url).toBe "/admin/#{product.storeSlug}/products/#{product._id}"
        expect(dataPosted.type).toBe "PUT"

    describe 'Does not update product when invalid', ->
      historySpy = ajaxSpy = product = store = null
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        ajaxSpy = spyOn($, 'ajax').andCallFake (opt) => opt.success()
        historySpy = spyOn(Backbone.history, "navigate")
        store = generator.store.a()
        product = generator.product.a()
        products = new Products [product], storeSlug: product.storeSlug
        productModel = products.at 0
        manageProductView = new ManageProductView el:el, product: productModel
        manageProductView.render()
        $("#name", el).val('').change()
        $("#price", el).val('d').change()
        $("#picture", el).val('e').change()
        $("#height", el).val('f').change()
        $("#width", el).val('g').change()
        $("#depth", el).val('h').change()
        $("#weight", el).val('i').change()
        $("#hasInventory", el).prop('checked', true).change()
        $("#inventory", el).val('j').change()
        $('#updateProduct', el).trigger 'click'
      xit 'did not update product', ->
        expect(ajaxSpy).not.toHaveBeenCalled()
      xit 'did not navigate', ->
        expect(historySpy).not.toHaveBeenCalled()
      it 'showed validation messages', ->
        expect($("#name ~ .tooltip .tooltip-inner", el).text()).toBe 'O nome é obrigatório.'
        expect($("#price ~ .tooltip .tooltip-inner", el).text()).toBe 'O preço deve ser um número.'
        expect($("#picture ~ .tooltip .tooltip-inner", el).text()).toBe 'A imagem deve ser uma url.'
        expect($("#height ~ .tooltip .tooltip-inner", el).text()).toBe 'A altura deve ser um número.'
        expect($("#width ~ .tooltip .tooltip-inner", el).text()).toBe 'A largura deve ser um número.'
        expect($("#depth ~ .tooltip .tooltip-inner", el).text()).toBe 'A profundidade deve ser um número.'
        expect($("#weight ~ .tooltip .tooltip-inner", el).text()).toBe 'O peso deve ser um número.'
        expect($("#inventory ~ .tooltip .tooltip-inner", el).text()).toBe 'O estoque deve ser um número.'
