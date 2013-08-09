define [
  'jquery'
  'twitterBootstrap'
], ($) ->
  $ ->
    $('.pop').popover
      html: true,
      title: -> $("##{@id}-head").html()
      content: -> $("##{@id}-content").html()
      placement: 'bottom'
      trigger: 'click'
    $('.pop').click (e) ->
      $('#email').focus()
      e.preventDefault()
      $('.popover-title .close').click ->
        $('.pop').popover 'hide'
