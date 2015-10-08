templates =
  friendAcceptedRequest: require './templates/friend_accepted_request'
  newCommentOnFollowedItem: require './templates/new_comment_on_followed_item'
  userMadeAdmin: require './templates/user_made_admin'

module.exports = Marionette.ItemView.extend
  tagName: 'li'
  className: ->
    status = @model.get 'status'
    "notification #{status}"

  getTemplate: ->
    notifType = @model.get 'type'
    template = templates[notifType]
    unless template? then return _.error 'notification type unknown'
    return template

  behaviors:
    PreventDefault: {}

  initialize: ->
    @lazyRender = _.LazyRender @
    @listenTo @model, 'change', @lazyRender
    @listenTo @model, 'grab', @lazyRender

  serializeData: -> @model.serializeData()

  events:
    'click .friendAcceptedRequest': 'showUserProfile'
    'click .newCommentOnFollowedItem': 'showItem'
    'click .userMadeAdmin': 'showGroupBoard'

  showUserProfile: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:user', @model.username
      app.execute 'notifications:menu:close'

  showItem: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:item:show:from:model', @model.item

  showGroupBoard: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:group:board', @model.group
