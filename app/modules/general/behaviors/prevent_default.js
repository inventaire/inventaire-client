// GENERAL RULE
// adding PreventDefault behavior is needed when a click event
// is catched by an event listener before app_layout preventDefault catchs it

export default Marionette.Behavior.extend({
  events: {
    'click a': require('modules/general/lib/smart_prevent_default')
  }
})
