getActionKey = require 'lib/get_action_key'

module.exports = Marionette.Behavior.extend
  events:
    'keyup .toggler-label': 'toggleCheckbox'
    # Convert touchstart events to click
    # on modules/general/views/templates/toggler.hbs
    'touchstart .toggler-label': (e)-> $(e.currentTarget).trigger 'click'

  toggleCheckbox: (e)->
    key = getActionKey e
    if key is 'enter'
      $(e.currentTarget).siblings('.toggler-input').trigger 'click'
