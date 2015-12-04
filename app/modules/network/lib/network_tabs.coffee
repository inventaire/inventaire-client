usersTabsDefault = 'searchUsers'
groupsTabsDefault = 'searchGroups'

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

addPath = (category, categoryData)->
  for key, obj of categoryData
    { section } = obj
    obj.parent = category
    obj.path = "network/#{category}/#{section}"

addPath 'users', usersTabs
addPath 'groups', groupsTabs

resolveCurrentTab = (tab)->
  switch tab
    when 'users' then usersTabsDefault
    when 'groups' then groupsTabsDefault
    else tab

module.exports =
  tabsData:
    all: _.extend {}, usersTabs, groupsTabs
    users: usersTabs
    groups: groupsTabs
  usersTabs: usersTabs
  groupsTabs: groupsTabs
  resolveCurrentTab: resolveCurrentTab
  getNameFromId: (id)-> id.replace 'Tab', ''
