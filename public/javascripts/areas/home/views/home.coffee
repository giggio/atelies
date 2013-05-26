define [
  'jquery'
  'backbone'
  'handlebars'
  '../models/productsHome'
  'text!./templates/home.html'
  'caroufredsel'
  'imagesloaded'
], ($, Backbone, Handlebars, ProductsHome, homeTemplate) ->
  class Home extends Backbone.View
    template: homeTemplate
    initialize: (opt) ->
      @products = opt.products
      @stores = opt.stores
    render: ->
      @$el.empty()
      productsHome = new ProductsHome()
      productsHome.reset @products
      context = Handlebars.compile @template
      @$el.html context productsHome: productsHome.toJSON(), stores: @stores
      $ ->
        $('#productsHome').imagesLoaded
          always: ->
            $('#productsHome').carouFredSel
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
