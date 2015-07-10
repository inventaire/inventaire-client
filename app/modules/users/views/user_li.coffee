relationsActions = require '../plugins/relations_actions'

module.exports = Marionette.ItemView.extend
  tagName: 'li'
  template: require './templates/user_li'
  className: ->
    classes = "userLi"
    status = @model.get('status') or 'noStatus'
    username = @model.get 'username'
    "userLi #{status} #{username}"

  behaviors:
    PreventDefault: {}
    ConfirmationModal: {}
    SuccessCheck: {}

  events:
    'click .select': 'selectUser'

  initialize:->
    # mutualizing the view with user in group context
    @group = @options.group
    @groupContext = @options.groupContext

    @initPlugins()
    @lazyRender = _.debounce @render, 200
    @listenTo @model, 'change', @lazyRender
    @listenTo @model, 'group:invite', @lazyRender
    @listenTo app.vent, "inventory:#{@model.id}:change", @lazyRender

  initPlugins: ->
    relationsActions.call @

  onShow: ->
    app.execute 'foundation:reload'

  serializeData: ->
    attrs = @model.serializeData()

    if @groupContext then @attachGroupsAttributes attrs
    else attrs

  attachGroupsAttributes: (attrs)->
    attrs.groupContext = true

    groupStatus = @group.userStatus @model
    attrs[groupStatus] = true

    return attrs

  selectUser: (e)->
    unless _.isOpenedOutside(e)
      app.execute 'show:inventory:user', @model
