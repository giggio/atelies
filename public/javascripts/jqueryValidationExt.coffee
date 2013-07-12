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
      return /^(?=(?:.*[A-z]){1})(?=(?:.*\d){1})(?=(?:.*[!@#$%^&*-]){1}).{8,}$/.test value
    , "A senha não é forte."
