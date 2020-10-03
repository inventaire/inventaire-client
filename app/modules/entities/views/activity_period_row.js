import { isOpenedOutside } from 'lib/utils'
export default Marionette.ItemView.extend({
  className: 'activityPeriodRow',
  template: require('./templates/activity_period_row.hbs'),
  tagName: 'tr',

  events: {
    'click .showUserContributions': 'showUserContributions'
  },

  showUserContributions (e) {
    if (!isOpenedOutside(e)) {
      app.execute('show:user:contributions', this.model.get('user')._id)
    }
  }
})
