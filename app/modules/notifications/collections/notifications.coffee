error_ = require 'lib/error'
{ models } = require '../lib/notifications_types'

module.exports = Backbone.Collection.extend
  comparator: (notif)-> - notif.get 'time'
  unread: -> @filter (model)-> model.get('status') is 'unread'
  unreadCount: -> @unread().length
  markAsRead: -> @each (model)-> model.set 'status', 'read'

  initialize: ->
    @toUpdate = []
    @batchUpdate = _.debounce @update.bind(@), 200

  updateStatus: (time)->
    @toUpdate.push time
    @batchUpdate()

  update: ->
    _.log @toUpdate, 'notifs:update'
    ids = @toUpdate
    @toUpdate = []
    _.preq.post app.API.notifications, { times: ids }
    .fail console.warn.bind(console)

  addPerType: (docs)->
    @add _.forceArray(docs).map(createTypedModel)

createTypedModel = (doc)->
  { type } = doc
  Model = models[type]
  unless Model?
    throw error_.new 'unknown notification type', doc

  return new Model(doc)
