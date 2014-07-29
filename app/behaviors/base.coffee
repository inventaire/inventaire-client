module.exports =
  initialize: ->
    Marionette.Behaviors.behaviorsLookup = ->
      app.Behaviors

  AlertBox: require 'behaviors/alertbox'
  Loading: require 'behaviors/loading'
  SuccessCheck: require 'behaviors/success_check'