relationsActions = require '../plugins/relations_actions'

module.exports = Marionette.ItemView.extend
  tagName: 'li'
  template: require './templates/user_li'
  className: ->
    classes = 'userLi'
    status = @model.get('status') or 'noStatus'
    stretch = if @options.stretch then 'stretch' else ''
    groupContext = if @options.groupContext then 'group-context' else ''
    "userLi #{status} #{stretch} #{groupContext}"

  behaviors:
    PreventDefault: {}
    SuccessCheck: {}

  events:
    # share js behavior, but avoid css collisions
    'click .select, .select-2': 'selectUser'

  initialize:->
    # mutualizing the view with user in group context
    @group = @options.group
    @groupContext = @options.groupContext

    @initPlugins()
    @lazyRender = _.LazyRender @, 200
    @listenTo @model, 'change', @lazyRender
    @listenTo @model, 'group:user:change', @lazyRender
    @listenTo app.vent, "inventory:#{@model.id}:change", @lazyRender

  initPlugins: ->
    relationsActions.call @

  serializeData: ->
    # nonPrivateInventoryLength is only a concern for the main user
    # which is only shown as a UserLi in the context of a group
    # thus the use of nonPrivateInventoryLength, as only non-private
    # items are integrating the group items counter
    nonPrivateInventoryLength = true
    attrs = @model.serializeData nonPrivateInventoryLength
    # required by the invitations by email users list
    attrs.showEmail = @options.showEmail
    attrs.stretch = @options.stretch
    if @groupContext then @customizeGroupsAttributes attrs
    return attrs

  customizeGroupsAttributes: (attrs)->
    attrs.groupContext = true

    groupStatus = @group.userStatus @model
    attrs[groupStatus] = true

    userId = @model.id

    # Override the general user.admin attribute to display an admin status
    # only for group admins
    attrs.admin = @group.userIsAdmin userId

    attrs.mainUserIsAdmin = @group.mainUserIsAdmin()

  selectUser: (e)->
    unless _.isOpenedOutside(e)
      app.execute 'show:inventory:user', @model
