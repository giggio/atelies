define [
  'jquery'
  'backboneConfig'
], ($, Backbone) ->
  class Search
    constructor: (opt) -> @searchTerm = opt?.searchTerm
    url: -> "/api/search/#{@searchTerm}"
    fetch: (opt) ->
      opt.url = @url()
      $.ajax opt
