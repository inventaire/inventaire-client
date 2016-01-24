Groups = require 'modules/network/collections/groups'
{ Updater } = require 'lib/model_update'

module.exports = ->
  groups = app.user?.groups or new Groups

  getGroupModel = (id)->
    group = groups.byId id
    if group? then _.preq.resolve group
    else getGroupPublicData id

  getGroupPublicData = (id)->
    _.preq.get _.buildPath(app.API.groups.public, {id: id})
    # .then _.Log('group public data')
    .then (res)->
      {group, users, items} = res
      app.execute 'users:public:add', users
      Items.public.add items
      groupModel =  groups.add group
      groupModel.publicDataOnly = true
      return groupModel

  groupSettingsUpdater = Updater
    endpoint: app.API.groups.private
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
    'fetch:last:group:created': fetchLastGroupsCreated

initGroupFilteredCollection = (groups, name)->
  filtered = groups[name] = new FilteredCollection groups
  filtered.filterBy name, filters[name]
  filtered.listenTo app.vent, 'group:main:user:move', filtered.refilter.bind(filtered)

filters =
  mainUserMember: (group)-> group.mainUserIsMember()
  mainUserInvited: (group)-> group.mainUserIsInvited()
