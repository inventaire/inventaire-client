module.exports = ConfirmationModal = Marionette.Behavior.extend
  events:
    'askConfirmation': 'askConfirmation'

  askConfirmation: (e, options)->
    view = new app.View.Behaviors.ConfirmationModal options
    app.layout.modal.show view