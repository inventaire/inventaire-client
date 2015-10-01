groupPlugin = require '../plugins/group'
GroupSettings = require './group_settings'

module.exports = Marionette.LayoutView.extend
  template: require './templates/group_board'
  className: 'groupBoard'
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
    settings: '#settings > .inner'
    requests: '#requests > .inner'
    members: '#members > .inner'
    invite: '#invite > .inner'

  ui:
    requests: '#requests'

  serializeData:->
    attrs = @model.serializeData()
    attrs.invitor = @invitorData()
    attrs["mainUser_#{@mainUserStatus}"] = true
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
    $el.slideToggle()
    $el.parent().find('.fa-caret-down').toggleClass 'toggled'

  onRender: ->
    @showMembers()
    if @mainUserIsAdmin then @showSettings()
    if @mainUserStatus is 'member' then @showFriendsInvitor()
    if @model.requested.length > 0 and @mainUserIsAdmin then @showJoinRequests()
    else @ui.requests.hide()

  showSettings: ->
    @settings.show new GroupSettings
      model: @model

  showJoinRequests: ->
    @requests.show @getJoinRequestsView()

  showMembers: ->
    @members.show @getGroupMembersListView()

  showFriendsInvitor: ->
    @invite.show @getFriendsInvitorView()