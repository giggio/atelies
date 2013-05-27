define 'app', ['jquery', 'jqval'], ($) ->
  start: ->
    $ -> $('.validatable').validate()
require ['bootstrap']
