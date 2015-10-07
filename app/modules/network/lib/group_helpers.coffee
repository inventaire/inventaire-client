Groups = require 'modules/network/collections/groups'
{ Updater } = require 'lib/model_update'

module.exports = ->
  groups = app.user?.groups or new Groups

  getGroupModel = (id)->
    group = groups.byId id
    if group then _.preq.resolve group
    else getGroupPublicData id

  getGroupPublicData = (id)->
    _.preq.get _.buildPath(app.API.groups.public, {id: id})
    .then _.Log('getGroupPublicData')
    .then (res)->
      {group, users, items} = res
      app.users.public.add users
      Items.public.add items
      groupModel =  groups.add group
      groupModel.publicDataOnly = true
      return groupModel

  groupSettingsUpdater = Updater
    endpoint: app.API.groups.private
    action: 'update-settings'
    modelIdLabel: 'group'

  getGroupsInCommon = (user)->
    return groups.filter (group)-> group.userStatus(user) isnt 'none'

  app.reqres.setHandlers
    'get:group:model': getGroupModel
    'get:group:model:sync': groups.byId.bind(groups)
    'group:update:settings': groupSettingsUpdater
    'get:groups:common': getGroupsInCommon

  initGroupFilteredCollection groups, 'mainUserMember'
  initGroupFilteredCollection groups, 'mainUserInvited'


initGroupFilteredCollection = (groups, name)->
  filtered = groups[name] = new FilteredCollection groups
  filtered.filterBy name, filters[name]
  filtered.listenTo app.vent, 'group:main:user:move', filtered.refilter.bind(filtered)

filters =
  mainUserMember: (group)-> group.mainUserIsMember()
  mainUserInvited: (group)-> group.mainUserIsInvited()
