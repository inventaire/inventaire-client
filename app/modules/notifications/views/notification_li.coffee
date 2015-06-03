module.exports = Marionette.ItemView.extend
  tagName: 'li'
  className: ->
    status = @model.get('status')
    "notification #{status}"
  getTemplate: ->
    switch @model.get('type')
      when 'friendAcceptedRequest'
        require './templates/friend_request_accepted'
      when 'newCommentOnFollowedItem'
        require './templates/new_comment_on_followed_item'
      else _.error 'notification type unknown'

  behaviors:
    PreventDefault: {}

  initialize: ->
    @listenTo @model, 'change', @render

  serializeData: ->
    attrs = @model.toJSON()
    @username = attrs.username = app.request 'get:username:from:userId', attrs.data.user
    attrs.picture = app.request 'get:profilePic:from:userId', attrs.data.user
    attrs.pathname = @pathnameData(attrs)
    if attrs.item?
      attrs.title = attrs.item.title
    return attrs

  events:
    'click .acceptedFriendRequest': 'showUserProfile'
    'click .newCommentOnFollowedItem': 'showItem'

  showUserProfile: (e)->
    unless _.isOpenedOutside(e)
      app.execute 'show:user', @username
      app.execute 'notifications:menu:close'

  showItem: (e)->
    unless _.isOpenedOutside(e)
      app.execute 'show:item:show:from:model', @model.item

  pathnameData: (attrs)->
    { username, item } = attrs
    switch @model.get('type')
      when 'friendAcceptedRequest' then "/inventory/#{username}"
      when 'newCommentOnFollowedItem'
        if item?
          return "/inventory/#{username}/#{item.entity}"
