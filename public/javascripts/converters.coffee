define ->
  class Converters
    @currency: (val) ->
      val = parseFloat val if typeof n isnt 'number'
      'R$ ' + val.toFixed(2).replace(/\./,',').replace /\B(?=(\d{3})+(?!\d))/g, "."
    @prettyDate: (d) -> "#{("0" + d.getDate()).slice -2}/#{("0" + (d.getMonth()+1)).slice -2}/#{d.getFullYear()}"
