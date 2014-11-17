module.exports = class ConfirmationModal extends Marionette.Behavior
  events:
    'askConfirmation': 'askConfirmation'

  askConfirmation: (e, options)->
    view = new app.View.Behaviors.ConfirmationModal options
    app.layout.modal.show view