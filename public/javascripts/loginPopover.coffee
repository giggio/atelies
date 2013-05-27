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
      template: '<div class="popover" onmouseover="$(this).mouseleave(function() {$(this).hide(); });"><div class="arrow"></div><div class="popover-inner"><h3 class="popover-title"></h3><div class="popover-content"><p></p></div></div></div>'
    $('.pop').click (e) ->
      $('#email').focus()
      e.preventDefault()
