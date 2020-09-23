import ActivityPeriod from './activity_period';

export default Marionette.LayoutView.extend({
  id: 'activityLayout',
  template: require('./templates/activity_layout'),
  regions: {
    lastDay: '#lastDay',
    lastWeek: '#lastWeek',
    global: '#global'
  },

  onShow() {
    this.lastDay.show(new ActivityPeriod({ title: 'last day', period: 1 }));
    this.lastWeek.show(new ActivityPeriod({ title: 'last 7 days', period: 7 }));
    return this.global.show(new ActivityPeriod({ title: 'global' }));
  }});
