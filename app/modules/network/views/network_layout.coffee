Tabs = require './tabs'
FriendsLayout = require './friends_layout'
GroupsLayout = require './groups_layout'

module.exports = Marionette.LayoutView.extend
  template: require './templates/network_layout'
  id: 'networkLayout'

  regions:
    tabs: '.custom-tabs-titles'
    content: '.custom-tabs-content'

  events:
    'click #friendsTab': 'showTabFriends'
    'click #groupsTab': 'showTabGroups'

  onShow: ->
    if @options.tab is 'groups' then @showTabGroups()
    else @showTabFriends()

  showTabFriends: ->
    @content.show new FriendsLayout @options
    @updateTabs 'friends'

  showTabGroups: ->
    @content.show new GroupsLayout @options
    @updateTabs 'groups'

  updateTabs: (tab)->
    @tabs.show new Tabs {tab: tab}
    app.navigate "network/#{tab}"
    tab = _.I18n tab
    network = _.I18n 'network'
    app.execute 'metadata:update:title', "#{tab} - #{network}"
