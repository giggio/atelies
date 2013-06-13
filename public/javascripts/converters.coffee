define ->
  class Converters
    @currency: (val) ->
      val = parseFloat val if typeof n isnt 'number'
      'R$ ' + val.toFixed(2).replace(/\./,',').replace /\B(?=(\d{3})+(?!\d))/g, "."
