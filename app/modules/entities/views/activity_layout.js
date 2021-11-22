import ActivityPeriod from './activity_period'
import activityLayoutTemplate from './templates/activity_layout.hbs'
import '../scss/activity_layout.scss'

export default Marionette.View.extend({
  id: 'activityLayout',
  template: activityLayoutTemplate,
  regions: {
    lastDay: '#lastDay',
    lastWeek: '#lastWeek',
    global: '#global'
  },

  onShow () {
    this.showChildView('lastDay', new ActivityPeriod({ title: 'last day', period: 1 }))
    this.showChildView('lastWeek', new ActivityPeriod({ title: 'last 7 days', period: 7 }))
    this.showChildView('global', new ActivityPeriod({ title: 'global' }))
  }
})
