FriendsLayout = require './friends_layout'
GroupsLayout = require './groups_layout'

module.exports = Marionette.LayoutView.extend
  template: require './templates/network_layout'
  id: 'networkLayout'

  regions:
    content: '.custom-tabs-content'

  ui:
    tabs: '.custom-tabs-titles a'
    friendsTab: '#friendsTab'
    groupsTab: '#groupsTab'

  events:
    'click #friendsTab': 'showTabFriends'
    'click #groupsTab': 'showTabGroups'

  onShow: ->
    if @options.tab is 'groups' then @showTabGroups()
    else @showTabFriends()

  showTabFriends: ->
    @content.show new FriendsLayout @options
    @updateTabs 'friends'
    app.navigate "network/friends"

  showTabGroups: ->
    @content.show new GroupsLayout @options
    @updateTabs 'groups'
    app.navigate "network/groups"

  updateTabs: (tab)->
    @ui.tabs.removeClass 'active'
    @ui["#{tab}Tab"].addClass 'active'
