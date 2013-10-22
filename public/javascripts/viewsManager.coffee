define [
  './seoLoadManager'
], (SEOLoadManager) ->
  class ViewsManager
    @show: (view) ->
      @view.close() if @view?
      @view = view
      @$el.html view.el
      view.render -> new SEOLoadManager().done()
