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
    @listenTo @model, 'action:leave', @render.bind(@)

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
    'click .section-toggler': 'toggleSection'
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
  toggleUi: (uiLabel, skipToggle=false)->
    $el = @ui[uiLabel]
    $parent = $el.parent()
    unless skipToggle then $el.slideToggle()
    $parent.find('.fa-caret-down').toggleClass 'toggled'
    if $el.visible() then _.scrollTop $parent

  onRender: ->
    @model.beforeShow()
    .then =>
      @showHeader()
      @showMembers()
      @showJoinRequests()
      if @model.mainUserIsMember()
        @initSettings()
        @showFriendsInvitor()

  onShow: ->
    @listenToOnce @model.requested, 'add', @showJoinRequests.bind(@)

  initSettings: ->
    if @options.standalone and @model.mainUserIsAdmin()
      @showSettings()
    else
      # begin with group_settings closed
      @toggleUi 'groupSettings'
      @_settingsShownOnce = false

  toggleSettings: ->
    if @_settingsShownOnce then @toggleUi 'groupSettings'
    else
      @showSettings()
      # no need to slideDown as showing the view
      # triggers a show action
      @toggleUi 'groupSettings', true

  showSettings: ->
    @_settingsShownOnce = true
    @groupSettings.show new GroupSettings
      model: @model

  showJoinRequests: ->
    if @model.requested.length > 0 and @model.mainUserIsAdmin()
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
