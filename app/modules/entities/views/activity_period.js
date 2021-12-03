import preq from 'lib/preq'
import ActivityPeriodRow from './activity_period_row'
import activityPeriodTemplate from './templates/activity_period.hbs'

export default Marionette.CollectionView.extend({
  className: 'activityPeriod',
  template: activityPeriodTemplate,
  childViewContainer: 'tbody',
  childView: ActivityPeriodRow,
  initialize () {
    this.collection = new Backbone.Collection();
    ({ title: this.title, period: this.period } = this.options)
    this.getActivityData()
  },

  serializeData () { return { title: this.title } },

  getActivityData () {
    return preq.get(app.API.entities.activity(this.period))
    .then(addUsersData)
    .then(this.addToCollection.bind(this))
  },

  addToCollection (activityRows) { return this.collection.add(activityRows) }
})

const addUsersData = async res => {
  const { activity: activityRows } = res
  if (activityRows.length === 0) return

  const usersIds = activityRows.map(_.property('user'))

  const { users } = await preq.get(app.API.users.byIds(usersIds))
  activityRows.forEach(row => { row.user = users[row.user] })
  return activityRows
}
