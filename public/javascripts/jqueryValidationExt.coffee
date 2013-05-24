define ->
  $ ->
    $.validator.addMethod "matches", (value, element, param) ->
      return false if $("##{param}").val() != $(element).val()
      return true
    , "Os campos não são iguais."
