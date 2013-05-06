require [
  'jquery'
], ($) ->
  el = $('<div><span id="some"></span></div>')
  describe 'HomeView', ->
    it 'should render the products', ->
      expect($('#some', el).length).toBe 1
