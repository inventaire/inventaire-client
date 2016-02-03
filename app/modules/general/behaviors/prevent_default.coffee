# GENERAL RULE
# adding PreventDefault behavior is needed when a click event is catched by an event listener before app_layout preventDefault catchs it

smartPreventDefault = require 'modules/general/lib/smart_prevent_default'

module.exports = Marionette.Behavior.extend
  events:
    'click a': 'smartPreventDefault'

  smartPreventDefault: smartPreventDefault
