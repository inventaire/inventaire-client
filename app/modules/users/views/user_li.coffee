relationsActions = require '../plugins/relations_actions'

module.exports = Marionette.ItemView.extend
  tagName: 'li'
  template: require './templates/user_li'
  className: ->
    classes = "userLi"
    status = @model.get('status') or 'noStatus'
    stretch = if @options.stretch then 'stretch' else ''
    groupContext = if @options.groupContext then 'group-context' else ''
    "userLi #{status} #{stretch} #{groupContext}"

  behaviors:
    PreventDefault: {}
    ConfirmationModal: {}
    SuccessCheck: {}

  events:
    # share js behavior, but avoid css collisions
    'click .select, .select-2': 'selectUser'

  initialize:->
    # mutualizing the view with user in group context
    @group = @options.group
    @groupContext = @options.groupContext

    @initPlugins()
    @lazyRender = _.debounce @render, 200
    @listenTo @model,
      'change': @lazyRender
      'group:user:change': @lazyRender
    @listenTo app.vent, "inventory:#{@model.id}:change", @lazyRender

  initPlugins: ->
    relationsActions.call @

  onShow: ->
    app.execute 'foundation:reload'

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
    if @groupContext then @attachGroupsAttributes attrs
    else attrs

  attachGroupsAttributes: (attrs)->
    attrs.groupContext = true

    groupStatus = @group.userStatus @model
    attrs[groupStatus] = true

    userId = @model.id
    if @group.userIsAdmin(userId) then attrs.admin = true

    attrs.mainUserIsAdmin = @group.mainUserIsAdmin()

    return attrs

  selectUser: (e)->
    unless _.isOpenedOutside(e)
      app.execute 'show:inventory:user', @model
