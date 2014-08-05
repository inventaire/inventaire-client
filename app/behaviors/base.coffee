module.exports =
  initialize: ->
    Marionette.Behaviors.behaviorsLookup = ->
      app.Behaviors

  AlertBox: require 'behaviors/alertbox'
  ConfirmationModal: require 'behaviors/confirmation_modal'
  Loading: require 'behaviors/loading'
  SuccessCheck: require 'behaviors/success_check'