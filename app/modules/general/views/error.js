import { isOpenedOutside } from 'lib/utils'
import errorTemplate from './templates/error.hbs'
import '../scss/error_layout.scss'
import PreventDefault from 'behaviors/prevent_default'

export default Marionette.View.extend({
  id: 'errorLayout',
  template: errorTemplate,
  behaviors: {
    PreventDefault,
  },

  serializeData () { return this.options },

  events: {
    'click .button': 'buttonAction'
  },

  ui: {
    errorBox: '.errorBox'
  },

  buttonAction (e) {
    if (!isOpenedOutside(e)) {
      const { buttonAction } = this.options.redirection
      if (_.isFunction(buttonAction)) buttonAction()
    }
  },

  onRender () {
    this.ui.errorBox.fadeIn()
  }
})
