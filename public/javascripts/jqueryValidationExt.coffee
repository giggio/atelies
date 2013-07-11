define [
  'jquery'
  'jqval'
], ($, validator) ->
  $ ->
    validator.addMethod "matches", (value, element, param) ->
      return false if $("##{param}").val() != $(element).val()
      return true
    , "Os campos não são iguais."
    validator.addMethod "strongPassword", (value, element) ->
      return /^(?=(?:.*[a-z]){1})(?=(?:.*[A-Z]){1})(?=(?:.*\d){1})(?=(?:.*[!@#$%^&*-]){1}).{10,}$/.test value
    , "A senha não é forte."
