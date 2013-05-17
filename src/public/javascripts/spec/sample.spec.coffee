define = require('amdefine')(module, requirejs) if (typeof define isnt 'function')
define [
  'jquery'
], ($) ->
  el = $('<div><span id="some">hello world</span></div>')
  describe 'HomeView', ->
    it 'should render the products', ->
      expect($('#some', el).text()).to.equal 'hello world'
