{ Updater } = require 'lib/model_update'

module.exports = ->
  { groups } = app

  getGroupModelById = (id)->
    group = groups.byId id
    unless group? then return getGroupPublicData id

    # the group model might have arrived from a simple search
    # thus without fetching its users
    if group.usersFetched then Promise.resolve group
    else getGroupPublicData null, group

  getGroupPublicData = (id, groupModel)->
    if groupModel? then id = groupModel.id
    _.preq.get app.API.groups.byId(id)
    .then (res)-> addGroupData res, groupModel

  getGroupModelFromSlug = (slug)->
    _.preq.get app.API.groups.bySlug(slug)
    .then addGroupData

  addGroupData = (res, groupModel)->
    { group, users } = res
    app.execute 'users:add', users
    groupModel ?= groups.add group
    groupModel.usersFetched = true
    return groupModel

  groupSettingsUpdater = Updater
    endpoint: app.API.groups.base
    action: 'update-settings'
    modelIdLabel: 'group'

  getGroupModel = (id)->
    if _.isGroupId(id) then getGroupModelById id
    else getGroupModelFromSlug id

  resolveToGroupModel = (group)->
    # 'group' is either the group model, a group id, or a group slug
    if _.isModel(group) then return Promise.resolve group

    getGroupModel group
    .then (groupModel)->
      if groupModel? then return groupModel
      else throw error_.new 'group model not found', 404, { group }

  app.reqres.setHandlers
    'get:group:model': getGroupModel
    'group:update:settings': groupSettingsUpdater
    'resolve:to:groupModel': resolveToGroupModel

  initGroupFilteredCollection groups, 'mainUserMember'
  initGroupFilteredCollection groups, 'mainUserInvited'

initGroupFilteredCollection = (groups, name)->
  filtered = groups[name] = new FilteredCollection groups
  filtered.filterBy name, filters[name]
  filtered.listenTo app.vent, 'group:main:user:move', filtered.refilter.bind(filtered)

filters =
  mainUserMember: (group)-> group.mainUserIsMember()
  mainUserInvited: (group)-> group.mainUserIsInvited()
