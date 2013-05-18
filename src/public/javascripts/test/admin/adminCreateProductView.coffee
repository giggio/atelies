define = require('amdefine')(module, requirejs) if (typeof define isnt 'function')
define [
  'jquery'
  'areas/admin/views/manageProduct'
  'areas/admin/models/product'
  'areas/admin/models/products'
  'backboneConfig'
  '../support/_specHelper'
], ($, ManageProductView, Product, Products) ->
  el = $('<div></div>')
  describe 'CreateProductView', ->
    describe 'Creates product', ->
      historySpy = productPosted = dataPosted = ajaxSpy = product = store = manageProductView = null
      before ->
        ajaxSpy = sinon.stub $, 'ajax', (opt) =>
          dataPosted = opt
          productPosted = JSON.parse opt.data
          opt.success(_id: '456')
        historySpy = sinon.spy Backbone.history, "navigate"
        store = generator.store.a()
        product = generator.product.a()
        product._id = undefined
        products = new Products [product], storeSlug: store.slug
        productModel = products.at 0
        manageProductView = new ManageProductView el:el, product: productModel
        manageProductView.render()
        $("#name", el).val(product.name).change()
        $("#price", el).val(product.price).change()
        $("#picture", el).val(product.picture).change()
        $("#tags", el).val(product.tags).change()
        $("#description", el).val(product.description).change()
        $("#height", el).val(product.height).change()
        $("#width", el).val(product.width).change()
        $("#depth", el).val(product.depth).change()
        $("#weight", el).val(product.weight).change()
        $("#hasInventory", el).prop('checked', product.hasInventory).change()
        $("#inventory", el).val(product.inventory).change()
        $('#updateProduct', el).trigger 'click'
      after ->
        ajaxSpy.restore()
        historySpy.restore()
      it 'created the product', ->
        expect(ajaxSpy).to.have.beenCalled
        expect(productPosted.name).to.equal product.name
        expect(productPosted.price).to.equal product.price
        expect(productPosted.picture).to.equal product.picture
        expect(productPosted.tags).to.equal product.tags
        expect(productPosted.description).to.equal product.description
        expect(productPosted.height).to.equal product.height
        expect(productPosted.width).to.equal product.width
        expect(productPosted.depth).to.equal product.depth
        expect(productPosted.weight).to.equal product.weight
        expect(productPosted.hasInventory).to.equal product.hasInventory
        expect(productPosted.inventory).to.equal product.inventory
      it 'navigated to store manage', ->
        expect(historySpy).to.have.been.calledWith "manageStore/#{product.storeSlug}", trigger:true
      it 'posted to correct url', ->
        expect(dataPosted.url).to.equal "/admin/#{product.storeSlug}/products"
        expect(dataPosted.type).to.equal "POST"

    describe 'Does not create product when invalid', ->
      historySpy = ajaxSpy = product = store = null
      before ->
        ajaxSpy = sinon.stub $, 'ajax', (opt) => opt.success()
        historySpy = sinon.spy Backbone.history, "navigate"
        store = generator.store.a()
        product = generator.product.a()
        product._id = undefined
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
      after ->
        ajaxSpy.restore()
        historySpy.restore()
      xit 'did not update product', ->
        expect(ajaxSpy).not.to.have.been.called
      xit 'did not navigate', ->
        expect(historySpy).not.to.have.been.called
      it 'showed validation messages', ->
        expect($("#name ~ .tooltip .tooltip-inner", el).text()).to.equal 'O nome é obrigatório.'
        expect($("#price ~ .tooltip .tooltip-inner", el).text()).to.equal 'O preço deve ser um número.'
        expect($("#picture ~ .tooltip .tooltip-inner", el).text()).to.equal 'A imagem deve ser uma url.'
        expect($("#height ~ .tooltip .tooltip-inner", el).text()).to.equal 'A altura deve ser um número.'
        expect($("#width ~ .tooltip .tooltip-inner", el).text()).to.equal 'A largura deve ser um número.'
        expect($("#depth ~ .tooltip .tooltip-inner", el).text()).to.equal 'A profundidade deve ser um número.'
        expect($("#weight ~ .tooltip .tooltip-inner", el).text()).to.equal 'O peso deve ser um número.'
        expect($("#inventory ~ .tooltip .tooltip-inner", el).text()).to.equal 'O estoque deve ser um número.'
