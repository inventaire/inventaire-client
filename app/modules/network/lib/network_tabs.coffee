usersTabs =
  searchUsers:
    name: 'searchUsers'
    section: 'search'
    title: 'search'
    icon: 'search'
    layout: 'users_search_layout'
  friends:
    name: 'friends'
    section: 'friends'
    title: 'friends'
    icon: 'list'
    layout: 'friends_layout'
    counter: 'friendsRequestsCount'
  invite:
    name: 'invite'
    section: 'invite'
    title: 'invite'
    icon: 'envelope'
    layout: 'invite_friends'
  nearbyUsers:
    name: 'nearbyUsers'
    section: 'nearby'
    title: 'nearby'
    icon: 'map-marker'
    layout: 'nearby_users_layout'

groupsTabs =
  searchGroups:
    name: 'searchGroups'
    section: 'search'
    title: 'search'
    icon: 'search'
    layout: 'groups_search_layout'
  userGroups:
    name: 'userGroups'
    section: 'user'
    title: 'your groups'
    icon: 'list'
    layout: 'groups_layout'
    counter: 'groupsRequestsCount'
  createGroup:
    name: 'createGroup'
    section: 'create'
    title: 'create'
    icon: 'plus'
    layout: 'create_group_layout'
  nearbyGroups:
    name: 'nearbyGroups'
    section: 'nearby'
    title: 'nearby'
    icon: 'map-marker'
    layout: 'nearby_groups_layout'

addPath = (category, categoryData)->
  for key, obj of categoryData
    { section } = obj
    obj.parent = category
    obj.path = "network/#{category}/#{section}"

addPath 'users', usersTabs
addPath 'groups', groupsTabs

defaultToSearch =
  users: -> app.relations.network.length is 0
  groups: -> app.groups.length is 0

getDefaultTab =
  general: -> getDefaultTab.users()
  users: -> if defaultToSearch.users() then 'searchUsers' else 'friends'
  groups: -> if defaultToSearch.groups() then 'searchGroups' else 'userGroups'

resolveCurrentTab = (tab)->
  switch tab
    when 'users' then getDefaultTab.users()
    when 'groups' then getDefaultTab.groups()
    else tab

tabsData =
  all: _.extend {}, usersTabs, groupsTabs
  users: usersTabs
  groups: groupsTabs

module.exports = {
  tabsData,
  usersTabs,
  groupsTabs,
  resolveCurrentTab,
  getNameFromId: (id)-> id.replace 'Tab', ''
  defaultToSearch,
  getDefaultTab,
  level1Tabs: [ 'users', 'groups' ]
}
