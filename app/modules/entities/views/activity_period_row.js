module.exports = Marionette.ItemView.extend
  className: 'activityPeriodRow'
  template: require './templates/activity_period_row'
  tagName: 'tr'

  events:
    'click .showUserContributions': 'showUserContributions'

  showUserContributions: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:user:contributions', @model.get('user')._id
