define [
  'jquery'
  'Backbone'
  'Handlebars'
  'productsHomeData'
  'models/ProductsHome'
  'text!views/templates/Home.html'
], ($, Backbone, Handlebars, productsHomeData, ProductsHome, homeTemplate) ->
  class Home extends Backbone.View
    template: homeTemplate
    render: ->
      @$el.empty()
      productsHome = new ProductsHome()
      productsHome.reset productsHomeData
      context = Handlebars.compile @template
      @$el.html context productsHome: productsHome.toJSON()
