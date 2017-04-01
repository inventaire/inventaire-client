groupPlugin = require '../plugins/group'
GroupBoardHeader = require './group_board_header'
GroupSettings = require './group_settings'

module.exports = Marionette.LayoutView.extend
  template: require './templates/group_board'
  className: ->
    standalone = if @options.standalone then 'standalone' else ''
    return "groupBoard #{standalone}"

  initialize: ->
    { @standalone } = @options
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
    @header.show new GroupBoardHeader { @model }

  toggleSection: (e)->
    section = e.currentTarget.parentElement.attributes.id.value

    if section is 'groupSettings' then @toggleSettings()
    else @toggleUi section

  # acting on ui objects and not a region.$el as a region
  # doesn't have a $el before being shown
  toggleUi: (uiLabel)->
    $el = @ui[uiLabel]
    $parent = $el.parent()
    $el.slideToggle()
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
    if @standalone and @model.mainUserIsAdmin()
      @showSettings()
      @listenTo @model, 'change:slug', @updateRoute.bind(@)
    else
      # begin with group_settings closed
      @toggleUi 'groupSettings'
      @_settingsShownOnce = false

  toggleSettings: ->
    if @_settingsShownOnce
      @toggleUi 'groupSettings'
    else
      @showSettings()
      @toggleUi 'groupSettings'

  showSettings: ->
    @_settingsShownOnce = true
    @groupSettings.show new GroupSettings { @model }

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

  updateRoute: ->
    app.navigateFromModel @model, 'boardPathname', { preventScrollTop: true }

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
