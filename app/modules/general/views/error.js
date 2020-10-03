import { isOpenedOutside } from 'lib/utils'
export default Marionette.LayoutView.extend({
  id: 'error',
  template: require('./templates/error.hbs'),
  behaviors: {
    PreventDefault: {}
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

  onShow () {
    app.execute('background:cover')
    this.ui.errorBox.fadeIn()
  }
})
