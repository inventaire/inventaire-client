module.exports =
  initialize: ->
    Marionette.Behaviors.behaviorsLookup = ->
      app.Behaviors

  SuccessCheck: require 'behaviors/success_check'