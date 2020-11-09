// GENERAL RULE
// adding PreventDefault behavior is needed when a click event
// is catched by an event listener before app_layout preventDefault catchs it

import smartPreventDefault from 'modules/general/lib/smart_prevent_default'

export default Marionette.Behavior.extend({
  events: {
    'click a': smartPreventDefault
  }
})
