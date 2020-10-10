import log_ from 'lib/loggers'
import preq from 'lib/preq'
import error_ from 'lib/error'
import { models as modelsTypes } from '../lib/notifications_types'

export default Backbone.Collection.extend({
  comparator (notif) { return -notif.get('time') },
  unread () { return this.filter(model => model.get('status') === 'unread') },
  unreadCount () { return this.unread().length },
  markAsRead () { return this.each(model => model.set('status', 'read')) },

  initialize () {
    this.toUpdate = []
    this.batchUpdate = _.debounce(this.update.bind(this), 200)
  },

  updateStatus (time) {
    this.toUpdate.push(time)
    return this.batchUpdate()
  },

  update () {
    log_.info(this.toUpdate, 'notifs:update')
    const ids = this.toUpdate
    this.toUpdate = []
    return preq.post(app.API.notifications, { times: ids })
    .catch(log_.Error('notification update err'))
  },

  addPerType (docs) {
    const models = docs
      .filter(doc => !deprecatedTypes.includes(doc.type))
      .map(createTypedModel)
    return this.add(models)
  },

  beforeShow () { return Promise.all(_.invoke(this.models, 'beforeShow')) }
})

const createTypedModel = function (doc) {
  const { type } = doc
  const Model = modelsTypes[type]
  if (Model == null) {
    throw error_.new('unknown notification type', doc)
  }

  return new Model(doc)
}

const deprecatedTypes = [ 'newCommentOnFollowedItem' ]
