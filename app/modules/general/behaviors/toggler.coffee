getActionKey = require 'lib/get_action_key'

module.exports = Marionette.Behavior.extend
  events:
    'keyup .toggler-label': 'toggleCheckbox'

  toggleCheckbox: (e)->
    key = getActionKey e
    if key is 'enter'
      $checkbox = $('.toggler-label').siblings '.toggler-input'
      bool = $checkbox.prop 'checked'
      $checkbox.prop 'checked', not bool

