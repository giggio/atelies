define ->
  class ViewsManager
    @show: (view) ->
      @view.close() if @view?
      @view = view
      view.render()
      @$el.html view.el
