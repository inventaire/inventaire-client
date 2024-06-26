import { debounce } from 'underscore'
import { API } from '#app/api/api'
import { newError } from '#app/lib/error'
import log_ from '#app/lib/loggers'
import preq from '#app/lib/preq'
import { models as modelsTypes } from '../lib/notifications_types.ts'

export default Backbone.Collection.extend({
  comparator (notif) { return -notif.get('time') },
  unread () { return this.filter(model => model.get('status') === 'unread') },
  unreadCount () { return this.unread().length },
  markAsRead () { return this.each(model => model.set('status', 'read')) },

  initialize () {
    this.toUpdate = []
    this.batchUpdate = debounce(this.update.bind(this), 200)
  },

  updateStatus (time) {
    this.toUpdate.push(time)
    return this.batchUpdate()
  },

  update () {
    log_.info(this.toUpdate, 'notifs:update')
    const ids = this.toUpdate
    this.toUpdate = []
    return preq.post(API.notifications, { times: ids })
    .catch(log_.Error('notification update err'))
  },

  addPerType (docs) {
    const models = docs
      .filter(doc => !deprecatedTypes.includes(doc.type))
      .map(createTypedModel)
    return this.add(models)
  },

  beforeShow () {
    const promises = this.models.map(model => model.beforeShow())
    return Promise.all(promises)
  },
})

const createTypedModel = function (doc) {
  const { type } = doc
  const Model = modelsTypes[type]
  if (Model == null) {
    throw newError('unknown notification type', doc)
  }

  return new Model(doc)
}

const deprecatedTypes = [ 'newCommentOnFollowedItem' ]
