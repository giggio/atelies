define [
  'backbone'
  'backboneValidation'
  'underscore'
  'epoxy'
], (Backbone, Validation, _) ->
  class OpenModel extends Backbone.Model
    validateOnSet: true
    idAttribute: "_id"
    initialize: (opt) ->
      @validateOnSet = opt.validateOnSet if opt?.validateOnSet?
      super
    set: (key, val, opt) ->
      return super key, val, opt unless @validateOnSet
      if typeof key is 'object'
        opt = val
        opt ||= {}
        opt.validate = true
        super key, opt
      else
        opt ||= {}
        opt.validate = true
        super key, val, opt
  OpenModel
