export default Marionette.ItemView.extend({
  className: 'activityPeriodRow',
  template: require('./templates/activity_period_row.hbs'),
  tagName: 'tr',

  events: {
    'click .showUserContributions': 'showUserContributions'
  },

  showUserContributions (e) {
    if (!_.isOpenedOutside(e)) {
      app.execute('show:user:contributions', this.model.get('user')._id)
    }
  }
})
