ActivityPeriod = require './activity_period'

module.exports = Marionette.LayoutView.extend
  id: 'activityLayout'
  template: require './templates/activity_layout'
  regions:
    lastDay: '#lastDay'
    lastWeek: '#lastWeek'
    global: '#global'

  onShow: ->
    @lastDay.show new ActivityPeriod { title: 'last day', period: 1 }
    @lastWeek.show new ActivityPeriod { title: 'last 7 days', period: 7 }
    @global.show new ActivityPeriod { title: 'global' }
