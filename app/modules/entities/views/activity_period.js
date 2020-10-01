import preq from 'lib/preq'
export default Marionette.CompositeView.extend({
  className: 'activityPeriod',
  template: require('./templates/activity_period'),
  childViewContainer: 'tbody',
  childView: require('./activity_period_row'),
  initialize () {
    this.collection = new Backbone.Collection();
    ({ title: this.title, period: this.period } = this.options)
    return this.getActivityData()
  },

  serializeData () { return { title: this.title } },

  getActivityData () {
    return preq.get(app.API.entities.activity(this.period))
    .then(addUsersData)
    .then(this.addToCollection.bind(this))
  },

  addToCollection (activityRows) { return this.collection.add(activityRows) }
})

const addUsersData = function (res) {
  const { activity: activityRows } = res
  if (activityRows.length === 0) return

  const usersIds = activityRows.map(_.property('user'))

  return preq.get(app.API.users.byIds(usersIds))
  .get('users')
  .then(users => {
    activityRows.forEach(row => { row.user = users[row.user] })
    return activityRows
  })
}
