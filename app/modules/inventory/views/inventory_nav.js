/* eslint-disable
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Marionette.ItemView.extend({
  template: require('./templates/inventory_nav'),
  initialize () {
    return ({ section: this.section } = this.options)
  },

  serializeData () {
    return {
      user: app.user.toJSON(),
      section: this.section
    }
  },

  events: {
    'click #tabs a': 'selectTab'
  },

  selectTab (e) {
    if (_.isOpenedOutside(e)) { return }
    const section = e.currentTarget.id.replace('Tab', '')
    app.execute('show:inventory:section', section)
    return e.preventDefault()
  }
})
