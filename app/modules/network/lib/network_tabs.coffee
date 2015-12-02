# tabsData =
#   users:
#     title: 'users'

users =
  friends:
    # parent: 'users'
    section: 'friends'
    title: 'your friends'
    Layout: require '../views/friends_layout'
  searchUsers:
    # parent: 'users'
    section: 'search'
    title: 'search'
    Layout: require '../views/users_search_layout'
  nearbyUsers:
    # parent: 'users'
    section: 'nearby'
    title: 'nearby'
    Layout: require '../views/nearby_users_layout'

  # groups:
  #   title: 'groups'

groups =
  userGroups:
    # parent: 'groups'
    title: 'your groups'
    section: 'user'
    Layout: require '../views/groups_layout'
  searchGroups:
    # parent: 'groups'
    section: 'search'
    title: 'search'
  nearbyGroups:
    # parent: 'groups'
    section: 'nearby'
    title: 'nearby'

# # keep the parent/children graph in sync
# for key, obj of tabsData
#   { parent, section } = obj
#   if parent?
#     # every child adds itself to its parent children list
#     # tabsData[parent].children or= []
#     # tabsData[parent].children.push key
#     obj.path = "network/#{parent}/#{section}"

addPath = (category, categoryData)->
  for key, obj of categoryData
    { section } = obj
    obj.parent = category
    obj.path = "network/#{category}/#{section}"

addPath 'users', users
addPath 'groups', groups

resolveCurrentTab = (tab)->
  switch tab
    # for every general tabs, display the first children tab by default
    when 'users' then 'friends'
    when 'groups' then 'userGroups'
    else tab

module.exports =
  tabsData: _.extend {}, users, groups
  resolveCurrentTab: resolveCurrentTab
