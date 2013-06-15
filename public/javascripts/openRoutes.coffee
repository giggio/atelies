define ->
  class Routes
    redirect: (to) ->
      Backbone.history.navigate to, trigger: true
