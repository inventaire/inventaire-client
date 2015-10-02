groupPlugin = require '../plugins/group'
GroupSettings = require './group_settings'

module.exports = Marionette.LayoutView.extend
  template: require './templates/group_board'
  className: ->
    standalone = if @options.standalone then 'standalone' else ''
    return "groupBoard #{standalone}"

  initialize: ->
    @initPlugin()
    @collection = @model.members
    @mainUserStatus = @model.mainUserStatus()
    @mainUserIsAdmin = @model.mainUserIsAdmin()

    @delayedRender = _.debounce @render.bind(@), 1000

    # let the time to success or fail signals to be shown
    @listenTo @model, 'change:name', @delayedRender
    @listenTo @model, 'change:picture', @delayedRender

  initPlugin: ->
    groupPlugin.call @

  behaviors:
    PreventDefault: {}

  regions:
    groupSettings: '#groupSettings > .inner'
    groupRequests: '#groupRequests > .inner'
    groupMembers: '#groupMembers > .inner'
    groupInvite: '#groupInvite > .inner'

  ui:
    groupRequests: '#groupRequests'

  serializeData:->
    attrs = @model.serializeData()
    attrs.invitor = @invitorData()
    attrs["mainUser_#{@mainUserStatus}"] = true
    attrs.sections = sectionsData
    return attrs

  invitorData: ->
    username = @model.findMainUserInvitor()?.get('username')
    return {username: username}

  events:
    'click .toggler': 'toggleSection'
    'click .joinRequest': 'requestToJoin'

  toggleSection: (e)->
    section = e.currentTarget.parentElement.attributes.id.value
    { $el } = @[section]
    @toggleEl $el

  toggleEl: ($el)->
    $el.slideToggle()
    $el.parent().find('.fa-caret-down').toggleClass 'toggled'

  onRender: ->
    @showMembers()
    if @mainUserIsAdmin then @showSettings()
    if @mainUserStatus is 'member' then @showFriendsInvitor()
    if @model.requested.length > 0 and @mainUserIsAdmin then @showJoinRequests()
    else @ui.groupRequests.hide()

  onShow: ->
    # toggled only once to start with settings hidden
    @toggleEl @groupSettings.$el

  showSettings: ->
    @groupSettings.show new GroupSettings
      model: @model

  showJoinRequests: ->
    @groupRequests.show @getJoinRequestsView()

  showMembers: ->
    @groupMembers.show @getGroupMembersListView()

  showFriendsInvitor: ->
    @groupInvite.show @getFriendsInvitorView()

sectionsData =
  settings:
    label: 'settings'
    icon: 'cog'
    # iconClasses: 'toggled'
  requests:
    label: 'requests waiting your approval'
    icon: 'inbox'
  members:
    label: 'members'
    icon: 'users'
  invite:
    label: 'invite friends'
    icon: 'envelope'
