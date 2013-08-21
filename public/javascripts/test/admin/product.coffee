define = require('amdefine')(module, requirejs) if (typeof define isnt 'function')
define [
  'jquery'
  'underscore'
  'backboneValidation'
  'areas/admin/models/product'
], ($, _, Validation, RealProduct) ->
  describe 'Product Model', ->
    class Product extends RealProduct
    _.extend Product::, Validation.mixin
    it 'does not validate when requires shipping info is not present', ->
      product = new Product()
      product.set 'name', 'aaa'
      product.set 'price', 12.14
      product.isValid(true).should.be.false
    it 'validates when required info is present and does not require shipping info', ->
      product = new Product()
      product.doNotRequireShippingInfo()
      product.set 'name', 'aaa'
      product.set 'price', 12.14
      product.isValid(true).should.be.true
    it 'When doesnt have shipping info does not validate shipping info', ->
      product = new Product()
      product.set 'name', 'aaa'
      product.set 'price', 12.14
      product.set 'shippingApplies', false
      product.isValid(true).should.be.true
    it 'When doesnt have shipping info and then it does it validates shipping info', ->
      product = new Product()
      product.set 'name', 'aaa'
      product.set 'price', 12.14
      product.isValid(true).should.be.false
      product.set 'shippingApplies', false
      product.set 'shippingApplies', true
      product.isValid(true).should.be.false
    it 'doesnt require shipping info if store does not auto calculate shipping', ->
      product = new Product()
      product.set 'name', 'aaa'
      product.set 'price', 12.14
      product.storeDoesNotRequireShippingInfo()
      product.set 'shippingApplies', true
      product.isValid(true).should.be.true
