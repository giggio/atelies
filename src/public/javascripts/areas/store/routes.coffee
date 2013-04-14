define [
  'jquery'
  './views/store'
],($, StoreView) ->
  home: ->
    storeView = new StoreView el:$("#app-container")
    storeView.render()
