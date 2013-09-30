define = require('amdefine')(module, requirejs) if (typeof define isnt 'function')
define [
  'jquery'
  'areas/admin/views/manageProduct'
  'areas/admin/models/product'
  'areas/admin/models/products'
  'areas/admin/models/store'
  'backboneConfig'
], ($, ManageProductView, Product, Products, Store) ->
  el = $('<div></div>')
  describe 'ManageProductView', ->
    storeModel2 = storeModel = newproduct = product = store = store2 = historySpy = productPosted = dataPosted = ajaxSpy = manageProductView = updatedProduct = null
    before ->
      product = generatorc.product.a()
      newproduct = generatorc.product.a()
      newproduct._id = undefined
      store = generatorc.store.a()
      storeModel = new Store store
      store2 = generatorc.store.b()
      storeModel2 = new Store store2
    describe 'Updating Product', ->
      describe 'Shows product', ->
        before ->
          ajaxSpy = sinon.stub $, 'ajax', (opt) =>
            dataPosted = opt
            opt.success []
          products = new Products [product], storeSlug: product.storeSlug
          productModel = products.at 0
          manageProductView = new ManageProductView el:el, product: productModel, store:storeModel
          manageProductView.render()
        it 'shows product', ->
          expect($("#_id", el).text()).to.equal product._id
          expect($("#name", el).val()).to.equal product.name
          expect($("#price", el).val()).to.equal product.price.toString()
          expect($("#slug", el).text()).to.equal product.slug
          expect($("#showPicture", el).attr('src')).to.equal product.picture
          expect($("#tags", el).val()).to.equal product.tags.split(/[\s,]+/).join()
          expect($("#description", el).val()).to.equal product.description
          expect($("#height", el).val()).to.equal product.height.toString()
          expect($("#width", el).val()).to.equal product.width.toString()
          expect($("#depth", el).val()).to.equal product.depth.toString()
          expect($("#weight", el).val()).to.equal product.weight.toString()
          expect($("#shippingCharge", el).prop('checked')).to.equal product.shippingCharge
          expect($("#shippingHeight", el).val()).to.equal product.shippingHeight.toString()
          expect($("#shippingWidth", el).val()).to.equal product.shippingWidth.toString()
          expect($("#shippingDepth", el).val()).to.equal product.shippingDepth.toString()
          expect($("#shippingWeight", el).val()).to.equal product.shippingWeight.toString()
          expect($("#hasInventory", el).prop('checked')).to.equal product.hasInventory
          expect($("#inventory", el).val()).to.equal product.inventory.toString()
        it 'loaded categories', ->
          expect(ajaxSpy).to.have.been.calledOnce
          dataPosted.url.should.equal "/admin/1/categories"
        after ->
          ajaxSpy.restore()
          manageProductView.close()
  
      describe 'Updates product', ->
        before ->
          productPosted = null
          ajaxSpy = sinon.stub $, 'ajax', (opt) =>
            return if opt.url is "/admin/1/categories"
            dataPosted = opt
            productPosted = JSON.parse opt.data
            opt.success()
          historySpy = sinon.spy Backbone.history, "navigate"
          product = generatorc.product.a()
          updatedProduct = generatorc.product.b()
          products = new Products [product], storeSlug: product.storeSlug
          productModel = products.at 0
          manageProductView = new ManageProductView el:el, product: productModel, store:storeModel
          manageProductView.render()
          $("#name", el).val(updatedProduct.name).change()
          $("#price", el).val(updatedProduct.price).change()
          $("#tags", el).val(updatedProduct.tags).change()
          $("#description", el).val(updatedProduct.description).change()
          $("#height", el).val(updatedProduct.height).change()
          $("#width", el).val(updatedProduct.width).change()
          $("#depth", el).val(updatedProduct.depth).change()
          $("#weight", el).val(updatedProduct.weight).change()
          $("#shippingCharge", el).prop('checked', updatedProduct.shippingCharge).change()
          $("#shippingHeight", el).val(updatedProduct.shippingHeight).change()
          $("#shippingWidth", el).val(updatedProduct.shippingWidth).change()
          $("#shippingDepth", el).val(updatedProduct.shippingDepth).change()
          $("#shippingWeight", el).val(updatedProduct.shippingWeight).change()
          $("#hasInventory", el).prop('checked', updatedProduct.hasInventory).change()
          $("#inventory", el).val(updatedProduct.inventory).change()
          $('#updateProduct', el).trigger 'click'
        after ->
          ajaxSpy.restore()
          historySpy.restore()
          manageProductView.close()
        it 'updated product', ->
          expect(ajaxSpy).to.have.been.calledTwice
          expect(productPosted.name).to.equal updatedProduct.name
          expect(productPosted.price).to.equal updatedProduct.price
          expect(productPosted.tags).to.equal updatedProduct.tags
          expect(productPosted.description).to.equal updatedProduct.description
          expect(productPosted.height).to.equal updatedProduct.height
          expect(productPosted.width).to.equal updatedProduct.width
          expect(productPosted.depth).to.equal updatedProduct.depth
          expect(productPosted.weight).to.equal updatedProduct.weight
          expect(productPosted.shippingCharge).to.equal updatedProduct.shippingCharge
          expect(productPosted.shippingHeight).to.equal updatedProduct.shippingHeight
          expect(productPosted.shippingWidth).to.equal updatedProduct.shippingWidth
          expect(productPosted.shippingDepth).to.equal updatedProduct.shippingDepth
          expect(productPosted.shippingWeight).to.equal updatedProduct.shippingWeight
          expect(productPosted.hasInventory).to.equal updatedProduct.hasInventory
          expect(productPosted.inventory).to.equal ''
        it 'navigated to store manage', ->
          expect(historySpy).to.have.been.calledWith "store/#{product.storeSlug}", trigger:true
        it 'posted to correct url', ->
          expect(dataPosted.url).to.equal "/admin/#{product.storeSlug}/products/#{product._id}"
          expect(dataPosted.type).to.equal "PUT"
  
      describe 'Does not update product when invalid', ->
        before ->
          ajaxSpy = sinon.stub $, 'ajax', (opt) =>
            return if opt.url is "/admin/1/categories"
            opt.success()
          historySpy = sinon.spy Backbone.history, "navigate"
          products = new Products [product], storeSlug: product.storeSlug
          productModel = products.at 0
          manageProductView = new ManageProductView el:el, product: productModel, store:storeModel
          manageProductView.render()
          $("#name", el).val('').change()
          $("#price", el).val('d').change()
          $("#height", el).val('f').change()
          $("#width", el).val('g').change()
          $("#depth", el).val('h').change()
          $("#weight", el).val('i').change()
          $("#shippingHeight", el).val('k').change()
          $("#shippingWidth", el).val('l').change()
          $("#shippingDepth", el).val('m').change()
          $("#shippingWeight", el).val('n').change()
          $("#hasInventory", el).prop('checked', true).change()
          $("#inventory", el).val('j').change()
          $('#updateProduct', el).trigger 'click'
        after ->
          ajaxSpy.restore()
          historySpy.restore()
          manageProductView.close()
        it 'did not update product', ->
          expect(ajaxSpy).to.have.been.calledOnce
        it 'did not navigate', ->
          expect(historySpy).not.to.have.been.called
        it 'showed validation messages', ->
          expect($("#name ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'O nome é obrigatório.'
          expect($("#price ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'O preço deve ser um número.'
          expect($("#height ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'A altura deve ser um número.'
          expect($("#width ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'A largura deve ser um número.'
          expect($("#depth ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'A profundidade deve ser um número.'
          expect($("#weight ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'O peso deve ser um número.'
          expect($("#shippingHeight ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'A altura deve ser um número entre 2 e 105.'
          expect($("#shippingWidth ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'A largura deve ser um número entre 11 e 105.'
          expect($("#shippingDepth ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'A profundidade deve ser um número entre 16 e 105.'
          expect($("#shippingWeight ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'O peso deve ser um número entre 0 e 30.'
          expect($("#inventory ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'O estoque deve ser um número.'

    describe 'Creating a Product', ->
      describe 'Creates product', ->
        before ->
          ajaxSpy = sinon.stub $, 'ajax', (opt) =>
            return if opt.url is "/admin/1/categories"
            dataPosted = opt
            productPosted = JSON.parse opt.data
            opt.success(_id: '456')
          historySpy = sinon.spy Backbone.history, "navigate"
          products = new Products [newproduct], storeSlug: store.slug
          productModel = products.at 0
          manageProductView = new ManageProductView el:el, product: productModel, store:storeModel
          manageProductView.render()
          $("#name", el).val(newproduct.name).change()
          $("#price", el).val(newproduct.price).change()
          $("#tags", el).val(newproduct.tags).change()
          $("#description", el).val(newproduct.description).change()
          $("#height", el).val(newproduct.height).change()
          $("#width", el).val(newproduct.width).change()
          $("#depth", el).val(newproduct.depth).change()
          $("#weight", el).val(newproduct.weight).change()
          $("#shippingCharge", el).prop('checked', newproduct.shippingCharge).change()
          $("#shippingHeight", el).val(newproduct.shippingHeight).change()
          $("#shippingWidth", el).val(newproduct.shippingWidth).change()
          $("#shippingDepth", el).val(newproduct.shippingDepth).change()
          $("#shippingWeight", el).val(newproduct.shippingWeight).change()
          $("#hasInventory", el).prop('checked', newproduct.hasInventory).change()
          $("#inventory", el).val(newproduct.inventory).change()
          $('#updateProduct', el).trigger 'click'
        after ->
          ajaxSpy.restore()
          historySpy.restore()
          manageProductView.close()
        it 'created the product', ->
          expect(ajaxSpy).to.have.been.called
          expect(productPosted.name).to.equal product.name
          expect(productPosted.price).to.equal product.price
          expect(productPosted.tags).to.equal product.tags
          expect(productPosted.description).to.equal product.description
          expect(productPosted.height).to.equal product.height
          expect(productPosted.width).to.equal product.width
          expect(productPosted.depth).to.equal product.depth
          expect(productPosted.weight).to.equal product.weight
          expect(productPosted.shippingCharge).to.equal product.shippingCharge
          expect(productPosted.shippingHeight).to.equal product.shippingHeight
          expect(productPosted.shippingWidth).to.equal product.shippingWidth
          expect(productPosted.shippingDepth).to.equal product.shippingDepth
          expect(productPosted.shippingWeight).to.equal product.shippingWeight
          expect(productPosted.hasInventory).to.equal product.hasInventory
          expect(productPosted.inventory).to.equal product.inventory
        it 'navigated to store manage', ->
          expect(historySpy).to.have.been.calledWith "store/#{product.storeSlug}", trigger:true
        it 'posted to correct url', ->
          expect(dataPosted.url).to.equal "/admin/#{product.storeSlug}/products"
          expect(dataPosted.type).to.equal "POST"
  
      describe 'Does not create product when invalid', ->
        before ->
          ajaxSpy = sinon.stub $, 'ajax', (opt) =>
            return if opt.url is "/admin/1/categories"
            opt.success()
          historySpy = sinon.spy Backbone.history, "navigate"
          products = new Products [newproduct], storeSlug: newproduct.storeSlug
          productModel = products.at 0
          manageProductView = new ManageProductView el:el, product: productModel, store:storeModel
          manageProductView.render()
          $("#name", el).val('').change()
          $("#price", el).val('d').change()
          $("#height", el).val('f').change()
          $("#width", el).val('g').change()
          $("#depth", el).val('h').change()
          $("#weight", el).val('i').change()
          $("#shippingHeight", el).val('f').change()
          $("#shippingWidth", el).val('g').change()
          $("#shippingDepth", el).val('h').change()
          $("#shippingWeight", el).val('i').change()
          $("#hasInventory", el).prop('checked', true).change()
          $("#inventory", el).val('j').change()
          $('#updateProduct', el).trigger 'click'
        after ->
          ajaxSpy.restore()
          historySpy.restore()
          manageProductView.close()
        it 'did not update product', ->
          expect(ajaxSpy).to.have.been.calledOnce
        it 'did not navigate', ->
          expect(historySpy).not.to.have.been.called
        it 'showed validation messages', ->
          expect($("#name ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'O nome é obrigatório.'
          expect($("#price ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'O preço deve ser um número.'
          expect($("#height ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'A altura deve ser um número.'
          expect($("#width ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'A largura deve ser um número.'
          expect($("#depth ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'A profundidade deve ser um número.'
          expect($("#weight ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'O peso deve ser um número.'
          expect($("#shippingHeight ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'A altura deve ser um número entre 2 e 105.'
          expect($("#shippingWidth ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'A largura deve ser um número entre 11 e 105.'
          expect($("#shippingDepth ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'A profundidade deve ser um número entre 16 e 105.'
          expect($("#shippingWeight ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'O peso deve ser um número entre 0 e 30.'
          expect($("#inventory ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'O estoque deve ser um número.'

      describe 'Does not create product when missing shipping info when product has shipping info', ->
        before ->
          ajaxSpy = sinon.stub $, 'ajax', (opt) =>
            return if opt.url is "/admin/1/categories"
            opt.success()
          historySpy = sinon.spy Backbone.history, "navigate"
          products = new Products [newproduct], storeSlug: newproduct.storeSlug
          productModel = products.at 0
          manageProductView = new ManageProductView el:el, product: productModel, store:storeModel
          manageProductView.render()
          $("#name", el).val(newproduct.name).change()
          $("#price", el).val(newproduct.price).change()
          $("#tags", el).val(newproduct.tags).change()
          $("#description", el).val(newproduct.description).change()
          $("#height", el).val(newproduct.height).change()
          $("#width", el).val(newproduct.width).change()
          $("#depth", el).val(newproduct.depth).change()
          $("#weight", el).val(newproduct.weight).change()
          $("#shippingHeight", el).val('').change()
          $("#shippingWidth", el).val('').change()
          $("#shippingDepth", el).val('').change()
          $("#shippingWeight", el).val('').change()
          $("#hasInventory", el).prop('checked', newproduct.hasInventory).change()
          $("#inventory", el).val(newproduct.inventory).change()
          $('#updateProduct', el).trigger 'click'
        after ->
          ajaxSpy.restore()
          historySpy.restore()
          manageProductView.close()
        it 'did not update product', ->
          expect(ajaxSpy).to.have.been.calledOnce
        it 'did not navigate', ->
          expect(historySpy).not.to.have.been.called
        it 'showed validation messages', ->
          expect($("#shippingHeight ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'A altura de postagem é obrigatória.'
          expect($("#shippingWidth ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'A largura de postagem é obrigatória.'
          expect($("#shippingDepth ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'A profundidade de postagem é obrigatória.'
          expect($("#shippingWeight ~ .tooltip .tooltip-inner :first", el).text()).to.equal 'O peso de postagem é obrigatório.'

      describe 'Creates a product when missing shipping info on a product that does not require it', ->
        before ->
          ajaxSpy = sinon.stub $, 'ajax', (opt) =>
            return if opt.url is "/admin/2/categories"
            dataPosted = opt
            productPosted = JSON.parse opt.data
            opt.success(_id: '456')
          historySpy = sinon.spy Backbone.history, "navigate"
          products = new Products [newproduct], storeSlug: store2.slug
          productModel = products.at 0
          manageProductView = new ManageProductView el:el, product: productModel, store:storeModel2
          manageProductView.render()
          $("#name", el).val(newproduct.name).change()
          $("#price", el).val(newproduct.price).change()
          $("#picture", el).val(newproduct.picture).change()
          $("#tags", el).val(newproduct.tags).change()
          $("#description", el).val(newproduct.description).change()
          $("#height", el).val(newproduct.height).change()
          $("#width", el).val(newproduct.width).change()
          $("#depth", el).val(newproduct.depth).change()
          $("#weight", el).val(newproduct.weight).change()
          $("#shippingHeight", el).val('').change()
          $("#shippingWidth", el).val('').change()
          $("#shippingDepth", el).val('').change()
          $("#shippingWeight", el).val('').change()
          $("#shippingDoesNotApply", el).click()
          $("#hasInventory", el).prop('checked', newproduct.hasInventory).change()
          $("#inventory", el).val(newproduct.inventory).change()
          $('#updateProduct', el).trigger 'click'
        after ->
          ajaxSpy.restore()
          historySpy.restore()
          manageProductView.close()
        it 'created the product', ->
          expect(ajaxSpy).to.have.been.called
          expect(productPosted.name).to.equal newproduct.name
          expect(productPosted.price).to.equal newproduct.price
          expect(productPosted.picture).to.equal newproduct.picture
          expect(productPosted.tags).to.equal newproduct.tags
          expect(productPosted.description).to.equal newproduct.description
          expect(productPosted.height).to.equal newproduct.height
          expect(productPosted.width).to.equal newproduct.width
          expect(productPosted.depth).to.equal newproduct.depth
          expect(productPosted.weight).to.equal newproduct.weight
          expect(productPosted.shippingHeight).to.equal ''
          expect(productPosted.shippingWidth).to.equal ''
          expect(productPosted.shippingDepth).to.equal ''
          expect(productPosted.shippingWeight).to.equal ''
          expect(productPosted.hasInventory).to.equal newproduct.hasInventory
          expect(productPosted.inventory).to.equal newproduct.inventory
        it 'navigated to store manage', ->
          expect(historySpy).to.have.been.calledWith "store/#{store2.slug}", trigger:true
        it 'posted to correct url', ->
          expect(dataPosted.url).to.equal "/admin/#{store2.slug}/products"
          expect(dataPosted.type).to.equal "POST"

    describe 'Deleting a Product', ->
      deleteStub = null
      describe 'Deletes product', ->
        before ->
          ajaxSpy = sinon.stub $, 'ajax', (opt) =>
            return if opt.url is "/admin/1/categories"
            dataPosted = opt
            opt.success()
          products = new Products [product], storeSlug: store.slug
          productModel = products.at 0
          manageProductView = new ManageProductView el:el, product: productModel, store:storeModel
          manageProductView.render()
          deleteStub = sinon.stub manageProductView, '_productDeleted'
          $('#deleteProduct', el).trigger 'click'
          $('#confirmDeleteProduct', el).trigger 'click'
        after ->
          ajaxSpy.restore()
          deleteStub.restore()
          manageProductView.close()
        it 'deleted the product', ->
          ajaxSpy.should.have.been.called
        it 'navigated to store manage', ->
          deleteStub.should.have.been.called
        it 'posted to correct url', ->
          expect(dataPosted.url).to.equal "/admin/#{product.storeSlug}/products/#{product._id}"
          expect(dataPosted.type).to.equal "DELETE"

      describe 'does not confirm product deletion', ->
        before ->
          ajaxSpy = sinon.stub $, 'ajax', (opt) =>
            return if opt.url is "/admin/1/categories"
            opt.success()
          products = new Products [product], storeSlug: store.slug
          productModel = products.at 0
          manageProductView = new ManageProductView el:el, product: productModel, store:storeModel
          manageProductView.render()
          deleteStub = sinon.stub manageProductView, '_productDeleted'
          $('#deleteProduct', el).trigger 'click'
          $('#noConfirmDeleteProduct', el).trigger 'click'
        after ->
          ajaxSpy.restore()
          deleteStub.restore()
          manageProductView.close()
        it 'did not delete the product', ->
          ajaxSpy.should.have.been.calledOnce
        it 'stays at the product manage page', ->
          deleteStub.should.not.have.been.called
