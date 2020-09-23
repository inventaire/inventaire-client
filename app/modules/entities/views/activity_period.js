module.exports = Marionette.CompositeView.extend
  className: 'activityPeriod'
  template: require './templates/activity_period'
  childViewContainer: 'tbody'
  childView: require './activity_period_row'
  initialize: ->
    @collection = new Backbone.Collection
    { @title, @period } = @options
    @getActivityData()

  serializeData: -> { @title }

  getActivityData: ->
    _.preq.get app.API.entities.activity(@period)
    .then addUsersData
    .then @addToCollection.bind(@)

  addToCollection: (activityRows)-> @collection.add activityRows

addUsersData = (res)->
  { activity:activityRows } = res
  if activityRows.length is 0 then return

  usersIds = activityRows.map _.property('user')

  _.preq.get app.API.users.byIds(usersIds)
  .get 'users'
  .then (users)->
    activityRows.forEach (row)-> row.user = users[row.user]
    return activityRows
