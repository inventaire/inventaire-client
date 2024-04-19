import { isFunction } from 'underscore'
import { isOpenedOutside } from '#app/lib/utils'
import PreventDefault from '#behaviors/prevent_default'
import errorTemplate from './templates/error.hbs'
import '../scss/error_layout.scss'

export default Marionette.View.extend({
  id: 'errorLayout',
  template: errorTemplate,
  behaviors: {
    PreventDefault,
  },

  serializeData () { return this.options },

  events: {
    'click .button': 'buttonAction',
  },

  ui: {
    errorBox: '.errorBox',
  },

  buttonAction (e) {
    if (!isOpenedOutside(e)) {
      const { buttonAction } = this.options.redirection
      if (isFunction(buttonAction)) buttonAction()
    }
  },
})
