getActionKey = require 'lib/get_action_key'

module.exports = Marionette.Behavior.extend
  events:
    'keyup .toggler-label': 'toggleCheckbox'

  toggleCheckbox: (e)->
    key = getActionKey e
    if key is 'enter'
      $(e.currentTarget).siblings('.toggler-input').trigger 'click'
