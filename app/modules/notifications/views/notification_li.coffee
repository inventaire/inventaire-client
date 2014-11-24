module.exports = class NotificationLi extends Backbone.Marionette.ItemView
  tagName: 'li'
  className: 'notification'
  getTemplate: ->
    switch @model.get('type')
      when 'friendAcceptedRequest' then require './templates/friend_request_accepted'
      else _.error 'notification type unknown'

  serializeData: ->
    attrs = @model.toJSON()
    attrs.username = app.request 'get:username:from:userId', attrs.data.user
    attrs.picture = app.request 'get:profilePic:from:userId', attrs.data.user
    attrs.href = '/inventory/' + attrs.username
    attrs.time = moment(attrs.time).fromNow()
    return attrs

  # events:
    # 'click a': 'showUserInventory'