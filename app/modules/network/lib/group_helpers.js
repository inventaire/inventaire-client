import { Updater } from 'lib/model_update'

export default function () {
  const { groups } = app

  const getGroupModelById = function (id) {
    const group = groups.byId(id)
    if (group == null) { return getGroupPublicData(id) }

    // the group model might have arrived from a simple search
    // thus without fetching its users
    if (group.usersFetched) {
      return Promise.resolve(group)
    } else { return getGroupPublicData(null, group) }
  }

  var getGroupPublicData = function (id, groupModel) {
    if (groupModel != null) {
      ({
        id
      } = groupModel)
    }
    return _.preq.get(app.API.groups.byId(id))
    .then(res => addGroupData(res, groupModel))
  }

  const getGroupModelFromSlug = slug => _.preq.get(app.API.groups.bySlug(slug))
  .then(addGroupData)

  var addGroupData = function (res, groupModel) {
    const { group, users } = res
    app.execute('users:add', users)
    if (groupModel == null) { groupModel = groups.add(group) }
    groupModel.usersFetched = true
    return groupModel
  }

  const groupSettingsUpdater = Updater({
    endpoint: app.API.groups.base,
    action: 'update-settings',
    modelIdLabel: 'group'
  })

  const getGroupModel = function (id) {
    if (_.isGroupId(id)) {
      return getGroupModelById(id)
    } else { return getGroupModelFromSlug(id) }
  }

  const resolveToGroupModel = function (group) {
    // 'group' is either the group model, a group id, or a group slug
    if (_.isModel(group)) { return Promise.resolve(group) }

    return getGroupModel(group)
    .then(groupModel => {
      if (groupModel != null) {
        return groupModel
      } else { throw error_.new('group model not found', 404, { group }) }
    })
  }

  app.reqres.setHandlers({
    'get:group:model': getGroupModel,
    'group:update:settings': groupSettingsUpdater,
    'resolve:to:groupModel': resolveToGroupModel
  })

  initGroupFilteredCollection(groups, 'mainUserMember')
  return initGroupFilteredCollection(groups, 'mainUserInvited')
};

var initGroupFilteredCollection = function (groups, name) {
  const filtered = (groups[name] = new FilteredCollection(groups))
  filtered.filterBy(name, filters[name])
  return filtered.listenTo(app.vent, 'group:main:user:move', filtered.refilter.bind(filtered))
}

var filters = {
  mainUserMember (group) { return group.mainUserIsMember() },
  mainUserInvited (group) { return group.mainUserIsInvited() }
}
