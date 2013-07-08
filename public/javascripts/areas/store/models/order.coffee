define [
  'backbone'
], (Backbone) ->
  class Order extends Backbone.Open.Model
    parse: (resp, opt) ->
      if resp.order?
        resp.order
      else
        resp
