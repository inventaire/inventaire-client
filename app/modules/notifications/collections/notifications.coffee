module.exports = Notifications = Backbone.Collection.extend
  model: require '../models/notification'
  unread: -> @filter (model)-> model.get('status') is 'unread'
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
    $.postJSON app.API.notifs, {times: ids}
    .fail console.warn.bind(console)