define [
  'jquery'
  'underscore'
  'backboneConfig'
  'handlebars'
  'text!./templates/_storeProducts.html'
], ($, _, Backbone, Handlebars, homeProductsTemplate) ->
  class HomeProductsView extends Backbone.Open.View
    template: homeProductsTemplate
    initialize: (opt) ->
      @products = opt.products
      @showProducts()
    showProducts: ->
      categories = @_groupCategories @products
      context = Handlebars.compile @template
      @$el.html context categories: categories, hasMoreThanOneCategory: categories.length > 1
    _groupCategories: (products) ->
      noCategory = "(sem categoria)"
      p.categories = [noCategory] for p in products when p.categories.length is 0
      categories = _.chain(products)
        .map((p) -> ({category:category, product: p} for category in p.categories))
        .flatten()
        .reduce(((memo, product) ->
          memo[product.category] = if memo[product.category]? then memo[product.category].concat([product.product]) else [product.product]
          memo), {} )
        .value()
      categoriesSorted = ( { category:category, products: @_groupProducts prods } for category, prods of categories )
      categoriesSorted = _.sortBy categoriesSorted, (c) -> c.category.toLowerCase()
      categoriesSorted.push categoriesSorted.shift() if categoriesSorted[0].category is noCategory
      categoriesSorted
    _groupProducts: (products) ->
      _.reduce products, (groups, product) ->
        if groups.length is 0 or _.last(groups).products.length is 6 then groups.push products:[]
        _.last(groups).products.push product
        groups
      , []
