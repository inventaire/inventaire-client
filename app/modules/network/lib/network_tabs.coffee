usersTabs =
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
  searchUsers:
    name: 'searchUsers'
    section: 'search'
    title: 'search'
    icon: 'search'
    layout: 'users_search_layout'
  nearbyUsers:
    name: 'nearbyUsers'
    section: 'nearby'
    title: 'nearby'
    icon: 'map-marker'
    layout: 'nearby_users_layout'

groupsTabs =
  userGroups:
    name: 'userGroups'
    section: 'user'
    title: 'your groups'
    icon: 'list'
    layout: 'groups_layout'
  searchGroups:
    name: 'searchGroups'
    section: 'search'
    title: 'search'
    icon: 'search'
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
    # for every general tabs, display the first children tab by default
    when 'users' then 'friends'
    when 'groups' then 'userGroups'
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
