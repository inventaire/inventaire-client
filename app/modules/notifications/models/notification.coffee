module.exports = Backbone.NestedModel.extend
  initialize: ->
    @on 'change:status', @update
    @initSpecific()

  # to override in inherinting models
  initSpecific: ->

  update: ->
    @collection.updateStatus @get('time')

  isUnread: -> @get('status') is 'unread'

  commonData: ->
    attrs = @toJSON()
    attrs.username = @getUsername()
    return attrs

  getUsername: ->
    app.request 'get:username:from:userId', @get('data.user')

  getUserPicture: ->
    app.request 'get:profilePic:from:userId', @get('data.user')
