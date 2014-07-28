module.exports =
  initialize: ->
    Marionette.Behaviors.behaviorsLookup = ->
      app.Behaviors

  Loading: require 'behaviors/loading'
  SuccessCheck: require 'behaviors/success_check'