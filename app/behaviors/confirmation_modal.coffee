module.exports = class ConfirmationModal extends Marionette.Behavior
  events:
    'askConfirmation': 'askConfirmation'

  askConfirmation: (e, params)->
    app.layout.modal.show new app.View.Behaviors.ConfirmationModal {params: params}