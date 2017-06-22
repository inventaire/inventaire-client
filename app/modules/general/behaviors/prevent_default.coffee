# GENERAL RULE
# adding PreventDefault behavior is needed when a click event is catched by an event listener before app_layout preventDefault catchs it

module.exports = Marionette.Behavior.extend
  events:
    'click a': require 'modules/general/lib/smart_prevent_default'
