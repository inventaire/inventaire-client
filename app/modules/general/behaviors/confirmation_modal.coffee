ConfirmationModal = require '../views/behaviors/confirmation_modal'

module.exports = Marionette.Behavior.extend
  events:
    'askConfirmation': 'askConfirmation'

  askConfirmation: (e, options)->
    app.layout.modal.show new ConfirmationModal(options)
