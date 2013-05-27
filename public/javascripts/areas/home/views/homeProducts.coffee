define [
  'jquery'
  'underscore'
  'backbone'
  'handlebars'
  '../models/productsHome'
  'text!./templates/_homeProducts.html'
  'caroufredsel'
  'imagesloaded'
], ($, _, Backbone, Handlebars, ProductsHome, homeProductsTemplate) ->
  class HomeProductsView extends Backbone.View
    template: homeProductsTemplate
    initialize: (opt) ->
      @products = opt.products
      @showProducts()
    showProducts: ->
      context = Handlebars.compile @template
      @$el.html context products: @products
      $ ->
        $('#products').imagesLoaded
          always: ->
            $('#carousel').carouFredSel
              scroll:
                items:1
                easing:'linear'
                duration: 1000
              width: '100%'
              auto:
                pauseOnHover: true
              prev:
                button  : "#carouselRight"
                key     : "right"
              next:
                button: "#carouselLeft"
                key: "left"
