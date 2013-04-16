define [
  'jquery'
  'backbone'
  'handlebars'
  'productsHomeData'
  '../models/productsHome'
  'text!./templates/home.html'
], ($, Backbone, Handlebars, productsHomeData, ProductsHome, homeTemplate) ->
  class Home extends Backbone.View
    template: homeTemplate
    render: ->
      @$el.empty()
      productsHome = new ProductsHome()
      productsHome.reset productsHomeData
      context = Handlebars.compile @template
      @$el.html context productsHome: productsHome.toJSON()
