groupPlugin = require '../plugins/group'
GroupBoardHeader = require './group_board_header'
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

    @_showSettings = false
    @_settingsReady = false

  initPlugin: ->
    groupPlugin.call @

  behaviors:
    PreventDefault: {}

  regions:
    header: '.header'
    groupSettings: '#groupSettings > .inner'
    groupRequests: '#groupRequests > .inner'
    groupMembers: '#groupMembers > .inner'
    groupInvite: '#groupInvite > .inner'

  ui:
    groupSettings: '#groupSettings > .inner'
    groupRequests: '#groupRequests > .inner'
    groupMembers: '#groupMembers > .inner'
    groupInvite: '#groupInvite > .inner'
    groupRequestsSection: '#groupRequests'

  serializeData:->
    attrs = @model.serializeData()
    attrs.sections = sectionsData
    return attrs

  events:
    'click .toggler': 'toggleSection'
    'click .joinRequest': 'requestToJoin'

  showHeader: ->
    @header.show new GroupBoardHeader
      model: @model

  toggleSection: (e)->
    section = e.currentTarget.parentElement.attributes.id.value

    if section is 'groupSettings' then @toggleSettings()
    else @toggleUi section

  # acting on ui objects and not a region.$el as a region
  # doesn't have a $el before being shown
  toggleUi: (uiLabel)->
    @ui[uiLabel].slideToggle()
    @toggleCaret uiLabel

  toggleCaret: (uiLabel, action)->
    actionFn = if action? then "#{action}Class" else 'toggleClass'
    @ui[uiLabel].parent().find('.fa-caret-down')[actionFn]('toggled')

  onRender: ->
    @showHeader()
    @showMembers()
    if @mainUserIsAdmin then @syncSettings()
    if @mainUserStatus is 'member' then @showFriendsInvitor()
    @showJoinRequests()

  onShow: ->
    @listenToOnce @model.requested, 'add', @showJoinRequests.bind(@)

  # should recover the last settings mode
  syncSettings: ->
    if @_showSettings then @showSettings()
    else @toggleUi 'groupSettings'

  showSettings: ->
    @_settingsReady = true
    @groupSettings.show new GroupSettings
      model: @model

  toggleSettings: ->
    # a rather hacky way to start with settings hidden
    # invert @_showSettings
    @_showSettings = not @_showSettings
    # make sure a group_settings view was rendered
    if @_showSettings and not @_settingsReady then @showSettings()
    if @_showSettings
      @ui.groupSettings.slideDown()
      @toggleCaret 'groupSettings', 'remove'
    else
      @ui.groupSettings.slideUp()
      @toggleCaret 'groupSettings', 'add'

  showJoinRequests: ->
    if @model.requested.length > 0 and @mainUserIsAdmin
      @groupRequests.show @getJoinRequestsView()
      @ui.groupRequestsSection.show()
    else
      @ui.groupRequestsSection.hide()

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
