define [
  'jquery'
  'backboneConfig'
  'handlebars'
  'underscore'
  'text!./templates/manageProduct.html'
  'text!./templates/validationErrors.html'
  '../models/product'
  '../models/products'
  'backboneValidation'
  'select2'
], ($, Backbone, Handlebars, _, manageProductTemplate, validationErrorsTemplate, Product, Products, Validation) ->
  class ManageProductView extends Backbone.Open.View
    events:
      'click #updateProduct':'_updateProduct'
      'click #confirmDeleteProduct':'_deleteProduct'
    @justCreated: false
    template: manageProductTemplate
    initialize: (opt) ->
      @model = opt.product
      @model.bind 'change:shippingApplies', _.bind @_showShippingOptions, @
      @store = opt.store
      @$el.html @template
      @_initializeBindings()
    render: ->
      @_setValidation()
      @_showShippingOptions()
      @_prepareSelects()
      super
    _initializeBindings: ->
      @bindings = @initializeBindings
        "#_id": "html:_id"
        "#slug": "html:slug"
        "#_id_holder": "toggle:_id"
        "#slug_holder": "toggle:slug"
        "#height": "value:integerOr(height)"
        "#width": "value:integerOr(width)"
        "#depth": "value:integerOr(depth)"
        "#weight": "value:decimalOr(weight)"
        "#shippingCharge": "checked:shippingCharge"
        "#shippingHeight": "value:integerOr(shippingHeight)"
        "#shippingWidth": "value:integerOr(shippingWidth)"
        "#shippingDepth": "value:integerOr(shippingDepth)"
        "#shippingWeight": "value:decimalOr(shippingWeight)"
        "#inventory": "value:integerOr(inventory)"
        "#price": "value:decimalOr(price)"
        "#hasInventory": "checked:hasInventory"
        "#shippingDoesNotApply": "checked:boolean(shippingApplies)"
        "#shippingDoesApply": "checked:boolean(shippingApplies)"
        "#showPicture": "attr:{src:picture}"

    _prepareSelects: ->
      @$('#tags').select2
        tags: []
        maximumInputLength: 30
        tokenSeparators: [","]
        formatNoMatches: -> ""
      $.ajax
        url: "/api/admin/#{@store.get '_id'}/categories"
        success: (data, status, jqxhr) =>
          cats = @$('#categories')
          cats.select2
            tags: data
            maximumInputLength: 30
            tokenSeparators: [","]
        error: (jqxhr, status, errorThrown) =>
          @showDialogError "Não foi possível obter as categorias. Tente novamente mais tarde."
          @logXhrError 'admin', jqxhr

    _setValidation: ->
      Validation.bind @
      validationErrorsEl = $('#validationErrors', @$el)
      valContext = Handlebars.compile validationErrorsTemplate
      _.defer =>
        @model.bind 'validated', (isValid, model, errors) ->
          if isValid
            validationErrorsEl.empty()
            validationErrorsEl.hide()
          else
            validationErrorsEl.html valContext errors:errors
            validationErrorsEl.show()
    _showShippingOptions: ->
      if @model.get 'shippingApplies'
        @$('#shippingInfo').show()
        @$('#shippingCharge').removeAttr('disabled')
      else
        @$('#shippingInfo').hide()
        @$('#shippingCharge').attr('disabled', 'disabled')
    _updateProduct: =>
      if @model.isValid true
        @$("#updateProduct").prop "disabled", on
        pictureVal = $('#picture').val()
        if typeof pictureVal isnt 'undefined' and pictureVal isnt ''
          @model.hasFiles = true
          @model.form = $('#editProduct')
        else
          @model.hasFiles = false
        @model.save @model.attributes,
          success: @_productUpdated
          error: (model, xhr, options) =>
            $("#updateProduct").prop "disabled", off
            if xhr.status is 422
              $('#sizeIsIncorrect .errorMsg', @$el).text JSON.parse(xhr.responseText).smallerThan
              return $('#sizeIsIncorrect').modal()
            if xhr.status is 409
              return @showDialog "Já há um produto nessa loja com esse nome. Cada produto da loja deve ter um nome direrente. Troque o nome e salve novamente.", "Erro ao salvar"
            @logXhrError 'admin', xhr
            @showDialogError "Não foi possível salvar o produto. Tente novamente mais tarde."
    _deleteProduct: =>
      @model.destroy
        wait:true
        success: @_productDeleted
        error: (model, xhr, options) =>
          @showDialogError "Não foi possível excluir o produto. Tente novamente mais tarde."
          @logXhrError 'admin', xhr
    _productUpdated: =>
      Backbone.history.navigate "store/#{@store.get('slug')}", trigger: true
    _productDeleted: =>
      @$('#confirmDeleteModal').one 'hidden.bs.modal', =>
        Backbone.history.navigate "store/#{@store.get('slug')}", trigger: true
      @$('#confirmDeleteModal').modal 'hide'
