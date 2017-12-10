groupPlugin = require '../plugins/group'
GroupBoardHeader = require './group_board_header'
GroupSettings = require './group_settings'
UsersSearchLayout = require '../views/users_search_layout'
UsersList = require 'modules/users/views/users_list'
InviteByEmail = require './invite_by_email'

module.exports = Marionette.LayoutView.extend
  template: require './templates/group_board'
  className: ->
    standalone = if @options.standalone then 'standalone' else ''
    return "groupBoard #{standalone}"

  initialize: ->
    { @standalone } = @options
    @initPlugin()
    @listenTo @model, 'action:accept', @render.bind(@)
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
    groupEmailInvite: '#groupEmailInvite > .inner'

  ui:
    groupSettings: '#groupSettings > .inner'
    groupRequests: '#groupRequests > .inner'
    groupMembers: '#groupMembers > .inner'
    groupInvite: '#groupInvite > .inner'
    groupEmailInvite: '#groupEmailInvite > .inner'
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
  toggleUi: (uiLabel, scroll=true)->
    $el = @ui[uiLabel]
    $parent = $el.parent()
    $el.slideToggle()
    $parent.find('.fa-caret-right').toggleClass 'toggled'
    if scroll and $el.visible() then _.scrollTop $parent, null, 20

  onRender: ->
    @model.beforeShow()
    .then @ifViewIsIntact('_showBoard')

  _showBoard: ->
    @showHeader()
    @showJoinRequests()
    @showMembers()
    if @model.mainUserIsMember()
      @initSettings()
      @showMembersInvitor()
      @showMembersEmailInvitor()

  initSettings: ->
    if @standalone and @model.mainUserIsAdmin()
      @showSettings()
      @listenTo @model, 'change:slug', @updateRoute.bind(@)
    else
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
      @_showJoinRequests()
      @ui.groupRequestsSection.show()
      @toggleUi 'groupRequests', false
    else
      @ui.groupRequestsSection.hide()

  _showJoinRequests: ->
    @groupRequests.show new UsersList
      collection: @model.requested
      groupContext: true
      group: @model
      emptyViewMessage: 'no more pending requests'

  showMembers: ->
    @groupMembers.show new UsersList
      collection: @model.members
      groupContext: true
      group: @model

  showMembersInvitor: ->
    group = @model
    @groupInvite.show new UsersSearchLayout
      stretch: false
      updateRoute: false
      groupContext: true
      group: group
      emptyViewMessage: 'no user found'
      filter: (user, index, collection)->
        group.userStatus(user) isnt 'member'

  showMembersEmailInvitor: ->
    @groupEmailInvite.show new InviteByEmail { group: @model }

  updateRoute: ->
    app.navigateFromModel @model, 'boardPathname', { preventScrollTop: true }

sectionsData =
  settings:
    label: 'settings'
    icon: 'cog'
  requests:
    label: 'requests waiting your approval'
    icon: 'inbox'
  members:
    label: 'members'
    icon: 'users'
  invite:
    label: 'invite new members'
    icon: 'plus'
  email:
    label: 'invite by email'
    icon: 'envelope'
