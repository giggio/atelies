define [
  'jquery'
  'underscore'
  'backbone'
  'handlebars'
  '../models/productsHome'
  'text!./templates/home.html'
  'caroufredsel'
  'imagesloaded'
], ($, _, Backbone, Handlebars, ProductsHome, homeTemplate) ->
  class Home extends Backbone.View
    template: homeTemplate
    initialize: (opt) ->
      @products = opt.products
      @stores = opt.stores
    render: ->
      context = Handlebars.compile @template
      storeGroups = _.reduce @stores, (groups, store) ->
        if groups.length is 0 or _.last(groups).stores.length is 4 then groups.push stores:[]
        _.last(groups).stores.push store
        groups
      , []
      @$el.html context storeGroups: storeGroups, products: @products
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
