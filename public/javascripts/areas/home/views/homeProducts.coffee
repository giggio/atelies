define [
  'jquery'
  'underscore'
  'backboneConfig'
  'handlebars'
  '../models/productsHome'
  'text!./templates/_homeProducts.html'
  'caroufredsel'
  'imagesloaded'
], ($, _, Backbone, Handlebars, ProductsHome, homeProductsTemplate) ->
  class HomeProductsView extends Backbone.Open.View
    template: homeProductsTemplate
    initialize: (opt) ->
      @products = opt.products
      @showProducts()
    showProducts: ->
      context = Handlebars.compile @template
      @$el.html context products: @products
      doCarousel = ->
        return showCarousel() if $('#carousel').length is 1
        setTimeout doCarousel
        , 500
      showCarousel = ->
        $('#carousel').carouFredSel
          scroll:
            items:1
            easing:'linear'
            duration: 1000
          width: '100%'
          auto:
            pauseOnHover: true
          prev:
            button  : "#carouselLeft"
            key     : "right"
          next:
            button: "#carouselRight"
            key: "left"
      $ ->
        $('#products').imagesLoaded
          always: -> setTimeout doCarousel, 200
        debounce = (wait, immediate, fn) -> _.debounce fn, wait, immediate
        $('section#app-container').on 'mouseenter', '#carousel .product', ->
          $('.productInfoBox', @).animate
            top: '-=50'
            height: '+=50'
          , 500, ->
            $('.storeName,.price', @).show()
          $('.storeName,.price', @).show()
        $('section#app-container').on 'mouseleave', '#carousel .product', ->
          $('.productInfoBox', @).animate
            top: '+=50'
            height: '-=50'
          , 500, ->
            $('.storeName,.price', @).hide()
