import ActivityPeriod from './activity_period'
import activityLayoutTemplate from './templates/activity_layout.hbs'
import '../scss/activity_layout.scss'

export default Marionette.LayoutView.extend({
  id: 'activityLayout',
  template: activityLayoutTemplate,
  regions: {
    lastDay: '#lastDay',
    lastWeek: '#lastWeek',
    global: '#global'
  },

  onShow () {
    this.lastDay.show(new ActivityPeriod({ title: 'last day', period: 1 }))
    this.lastWeek.show(new ActivityPeriod({ title: 'last 7 days', period: 7 }))
    this.global.show(new ActivityPeriod({ title: 'global' }))
  }
})
