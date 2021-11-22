import { isOpenedOutside } from 'lib/utils'
import activityPeriodRowTemplate from './templates/activity_period_row.hbs'

export default Marionette.View.extend({
  template: activityPeriodRowTemplate,
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
