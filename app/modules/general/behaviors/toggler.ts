import { getActionKey } from '#app/lib/key_events'

// @ts-expect-error
export default Marionette.Behavior.extend({
  events: {
    'keyup .toggler-label': 'toggleCheckbox',
    // Convert touchstart events to click
    // on modules/general/views/templates/toggler.hbs
    'touchstart .toggler-label' (e) {
      $(e.currentTarget).trigger('click')
    },
  },

  toggleCheckbox (e) {
    const key = getActionKey(e)
    if (key === 'enter') {
      $(e.currentTarget).siblings('.toggler-input').trigger('click')
    }
  },
})
