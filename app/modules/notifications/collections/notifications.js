import preq from 'lib/preq'
import error_ from 'lib/error'
import { models } from '../lib/notifications_types'

export default Backbone.Collection.extend({
  comparator (notif) { return -notif.get('time') },
  unread () { return this.filter(model => model.get('status') === 'unread') },
  unreadCount () { return this.unread().length },
  markAsRead () { return this.each(model => model.set('status', 'read')) },

  initialize () {
    this.toUpdate = []
    return this.batchUpdate = _.debounce(this.update.bind(this), 200)
  },

  updateStatus (time) {
    this.toUpdate.push(time)
    return this.batchUpdate()
  },

  update () {
    _.log(this.toUpdate, 'notifs:update')
    const ids = this.toUpdate
    this.toUpdate = []
    return preq.post(app.API.notifications, { times: ids })
    .catch(_.Error('notification update err'))
  },

  addPerType (docs) {
    models = docs
      .filter(doc => !deprecatedTypes.includes(doc.type))
      .map(createTypedModel)
    return this.add(models)
  },

  beforeShow () { return Promise.all(_.invoke(this.models, 'beforeShow')) }
})

const createTypedModel = function (doc) {
  const { type } = doc
  const Model = models[type]
  if (Model == null) {
    throw error_.new('unknown notification type', doc)
  }

  return new Model(doc)
}

const deprecatedTypes = [ 'newCommentOnFollowedItem' ]
