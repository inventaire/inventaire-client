{ GroupLayoutView } = require './group_views_commons'
GroupBoardHeader = require './group_board_header'
GroupSettings = require './group_settings'
UsersSearchLayout = require '../views/users_search_layout'
UsersList = require 'modules/users/views/users_list'
InviteByEmail = require './invite_by_email'
screen_ = require 'lib/screen'

module.exports = GroupLayoutView.extend
  template: require './templates/group_board'
  className: ->
    standalone = if @options.standalone then 'standalone' else ''
    return "groupBoard #{standalone}"

  initialize: ->
    { @standalone, @openedSection } = @options

    # Join requests will be showned instead
    if @openedSection is 'groupSettings' and @model.mainUserIsAdmin() and @model.get('requested').length > 0
      @openedSection = null

    @_alreadyShownSection = {}
    @listenTo @model, 'action:accept', @render.bind(@)
    @listenTo @model, 'action:leave', @onLeave.bind(@)

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

  events: _.extend {}, GroupLayoutView::events,
    'click .section-toggler': 'toggleSection'

  onShow: ->
    if @openedSection? then @toggleUi @openedSection

  showHeader: ->
    @header.show new GroupBoardHeader { @model }

  toggleSection: (e)->
    section = e.currentTarget.parentElement.attributes.id.value
    @toggleUi section

  # acting on ui objects and not a region.$el as a region
  # doesn't have a $el before being shown
  toggleUi: (uiLabel, scroll = true)->
    if not @_alreadyShownSection[uiLabel] and @onFirstToggle[uiLabel]?
      fnName = @onFirstToggle[uiLabel]
      @[fnName]()
      @_alreadyShownSection = true

    @_toggleUi uiLabel

  _toggleUi: (uiLabel)->
    $el = @ui[uiLabel]
    $parent = $el.parent()
    $el.slideToggle()
    $parent.find('.fa-caret-right').toggleClass 'toggled'
    if scroll and $el.visible() then screen_.scrollTop $parent, null, 20

  onFirstToggle:
    groupSettings: 'showSettings'
    groupMembers: 'showMembers'
    groupRequests: 'showJoinRequests'
    groupInvite: 'showMembersInvitor'
    groupEmailInvite: 'showMembersEmailInvitor'

  onRender: ->
    @model.beforeShow()
    .then @ifViewIsIntact('_showBoard')

  _showBoard: ->
    @showHeader()
    @prepareJoinRequests()
    if @model.mainUserIsMember() then @initSettings()

  initSettings: ->
    if @standalone and @model.mainUserIsAdmin()
      @listenTo @model, 'change:slug', @updateRoute.bind(@)

  showSettings: ->
    @groupSettings.show new GroupSettings { @model }

  prepareJoinRequests: ->
    if @model.requested.length > 0 and @model.mainUserIsAdmin()
      @ui.groupRequestsSection.show()
      @toggleUi 'groupRequests', false
    else
      @ui.groupRequestsSection.hide()

  showJoinRequests: ->
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
    # TODO: replace UsersSearchLayout by a user list fed with search results
    # that aren't added to the deprecated global users collections
    @groupInvite.show new UsersSearchLayout
      stretch: false
      updateRoute: false
      groupContext: true
      group: group
      emptyViewMessage: 'no user found'
      filter: (user, index, collection)->
        group.userStatus(user) isnt 'member'

  onLeave: -> app.execute 'show:inventory:group', @model, true

  showMembersEmailInvitor: ->
    @groupEmailInvite.show new InviteByEmail { group: @model }

  updateRoute: ->
    app.navigateFromModel @model, 'boardPathname', { preventScrollTop: true }

sectionsData =
  settings:
    label: 'group settings'
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
