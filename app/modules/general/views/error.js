/* eslint-disable
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Marionette.LayoutView.extend({
  id: 'error',
  template: require('./templates/error'),
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
    if (!_.isOpenedOutside(e)) {
      const { buttonAction } = this.options.redirection
      if (_.isFunction(buttonAction)) { return buttonAction() }
    }
  },

  onShow () {
    app.execute('background:cover')
    return this.ui.errorBox.fadeIn()
  }
})
