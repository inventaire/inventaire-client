/* eslint-disable
    import/no-duplicates,
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import getActionKey from 'lib/get_action_key'

export default Marionette.Behavior.extend({
  events: {
    'keyup .toggler-label': 'toggleCheckbox',
    // Convert touchstart events to click
    // on modules/general/views/templates/toggler.hbs
    'touchstart .toggler-label' (e) { return $(e.currentTarget).trigger('click') }
  },

  toggleCheckbox (e) {
    const key = getActionKey(e)
    if (key === 'enter') {
      return $(e.currentTarget).siblings('.toggler-input').trigger('click')
    }
  }
})
