/* eslint-disable
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Marionette.ItemView.extend({
  className: 'activityPeriodRow',
  template: require('./templates/activity_period_row'),
  tagName: 'tr',

  events: {
    'click .showUserContributions': 'showUserContributions'
  },

  showUserContributions (e) {
    if (!_.isOpenedOutside(e)) {
      return app.execute('show:user:contributions', this.model.get('user')._id)
    }
  }
})
