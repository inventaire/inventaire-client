{ Updater } = require 'lib/model_update'

module.exports = ->
  { groups } = app

  getGroupModel = (id)->
    group = groups.byId id
    unless group? then return getGroupPublicData id

    # the group model might have arrived from a simple search
    # thus without fetching its users
    if group.usersFetched then _.preq.resolve group
    else getGroupPublicData null, group

  getGroupPublicData = (id, groupModel)->
    if groupModel? then id = groupModel.id
    _.preq.get app.API.groups.byId(id)
    .then (res)->
      { group, users } = res
      app.execute 'users:public:add', users
      groupModel ?= groups.add group
      groupModel.usersFetched = true
      return groupModel

  groupSettingsUpdater = Updater
    endpoint: app.API.groups.authentified
    action: 'update-settings'
    modelIdLabel: 'group'

  getGroupsInCommon = (user)->
    return groups.filter (group)->
      return group.mainUserIsMember() and group.userStatus(user) is 'member'

  # returns the groups the main user visited in this session
  # but isnt a member of
  otherVisitedGroups = (user)->
    return groups.filter (group)->
      mainUserIsntMember = not group.mainUserIsMember()
      return mainUserIsntMember and group.userStatus(user) is 'member'

  app.reqres.setHandlers
    'get:group:model': getGroupModel
    'get:group:model:sync': groups.byId.bind(groups)
    'group:update:settings': groupSettingsUpdater
    'get:groups:common': getGroupsInCommon
    'get:groups:others:visited': otherVisitedGroups

  initGroupFilteredCollection groups, 'mainUserMember'
  initGroupFilteredCollection groups, 'mainUserInvited'

  groups.filtered = require('./groups_search')(groups)

  lastGroupFetched = false
  fetchLastGroupsCreated = ->
    # prevent it to be queried several times per sessions
    unless lastGroupFetched
      lastGroupFetched = true
      _.preq.get app.API.groups.last
      .then groups.add.bind(groups)
      .catch _.ErrorRethrow('fetchLastGroupsCreated')

  app.commands.setHandlers
    'fetch:last:groups:created': fetchLastGroupsCreated

initGroupFilteredCollection = (groups, name)->
  filtered = groups[name] = new FilteredCollection groups
  filtered.filterBy name, filters[name]
  filtered.listenTo app.vent, 'group:main:user:move', filtered.refilter.bind(filtered)

filters =
  mainUserMember: (group)-> group.mainUserIsMember()
  mainUserInvited: (group)-> group.mainUserIsInvited()
