define [
  'jquery'
  'backboneConfig'
  'handlebars'
  'showdown'
  './storeProducts'
  'text!./templates/store.html'
  './productsSearchResults'
], ($, Backbone, Handlebars, Showdown, ProductsView, storeTemplate, ProductsSearchResultsView) ->
  class StoreView extends Backbone.Open.View
    template: storeTemplate
    initialize: (opt) ->
      @store = opt.store
      @products = opt.products
      @markdown = new Showdown.converter()
    render: ->
      @$el.empty()
      context = Handlebars.compile @template
      homePageDescription = @markdown.makeHtml @store.homePageDescription
      @$el.html context store: @store, staticPath: @staticPath, homePageDescription: homePageDescription
      @productsView = new ProductsView products:@products
      @$('#productsPlaceHolder').html @productsView.el
    showProductsSearchResults: (searchTerm, products) ->
      $('#productSearchTerm').val searchTerm
      productsSearchResultsView = new ProductsSearchResultsView products:products
      @$('#productsPlaceHolder').html productsSearchResultsView.el
