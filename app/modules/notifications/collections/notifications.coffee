models =
  friendAcceptedRequest: require '../models/friend_accepted_request'
  newCommentOnFollowedItem: require '../models/new_comment_on_followed_item'
  userMadeAdmin: require '../models/user_made_admin'

module.exports = Backbone.Collection.extend
  comparator: (notif)-> - notif.get 'time'
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

  addPerType: (docs)->
    @add _.forceArray(docs).map(createTypedModel)

createTypedModel = (doc)->
  { type } = doc
  Model = models[type]
  unless Model
    _.error doc, 'unknown notification type'
    return

  return new Model(doc)
